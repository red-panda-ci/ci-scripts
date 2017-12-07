#!/bin/bash

signApk="$(basename "$0" | sed -e 's/-/ /')"
HELP="Usage: ${signApk} [options...]

Sign apk

Options:
  --sdkVersion=xx.y.z                        # use sdk version xx.y.z
  --signingRepository='repository_uri'       # signing repository url, 'git@...'
  --signingPath='path_to_the_sign_elements'  # signing elements path within repository
  --artifactPath='path_to_the_artifact_file' # path to the apk artifact file to be signed

All options are mandatory

Example:
  ${signApk} \\
      --sdkVersion='23.0.3' \\
      --signingRepository='git@bitbucket.org:company/company-sign-repository.git' \\
      --signingPath='the-project/sign' \\
      --artifactPath='app/build/outputs/apk/app-release-unsigned.apk'
"

cd "$(dirname "$0")/.."
ciRootFolder="$(pwd)"
cd "../.."
appFolder="$(pwd)"

# Parse variables
sdkVersion=""
signingRepository=""
signingPath=""
artifactPath=""
while [ $# -gt 0 ]; do
  case "$1" in
    --sdkVersion=*)
      sdkVersion="${1#*=}"
      ;;
    --signingRepository=*)
      signingRepository="${1#*=}"
      ;;
    --signingPath=*)
      signingPath="${1#*=}"
      ;;
    --artifactPath=*)
      artifactPath="${1#*=}"
      ;;
    --h|\?|--help)
      echo "${HELP}"
      exit 0
      ;;
    *)
      printf "[ERROR] Invalid argument '$1 '\n"
      echo "${HELP}"
      exit 0
  esac
  shift
done

# Check parameters
if [ "${sdkVersion}" == "" ]
then
  echo "[ERORR]: you must specify --sdkVersion option"
  echo
  echo "${HELP}"
  exit 1
fi
if [ "${signingRepository}" == "" ]
then
  echo "[ERORR]: you must specify --signingRepository option"
  echo
  echo "${HELP}"
  exit 1
fi
if [ "${signingPath}" == "" ]
then
  echo "[ERORR]: you must specify --signingPath option"
  echo
  echo "${HELP}"
  exit 1
fi
if [ "${artifactPath}" == "" ]
then
  echo "[ERORR]: you must specify --artifactPath option"
  echo
  echo "${HELP}"
  exit 1
fi

signedUnalignedArtifactPath=$(echo ${artifactPath}|sed 's/-unsigned.apk/-signed-unaligned.apk/g')
signedAlignedArtifactPath=$(echo ${artifactPath}|sed 's/-unsigned.apk/-signed-aligned.apk/g')
repositoryBasePath="ci-scripts/.signing_repository"
rm -rf ${repositoryBasePath} && mkdir -p ${repositoryBasePath} && git clone ${signingRepository} ${repositoryBasePath}
STORE_PASSWORD=$(cat "${repositoryBasePath}/${signingPath}/credentials.json" |jq -r '.STORE_PASSWORD')
KEY_ALIAS=$(cat "${repositoryBasePath}/${signingPath}/credentials.json" |jq -r '.KEY_ALIAS')
KEY_PASSWORD=$(cat "${repositoryBasePath}/${signingPath}/credentials.json" |jq -r '.KEY_PASSWORD')
ARTIFACT_SHA1=$(cat "${repositoryBasePath}/${signingPath}/credentials.json" |jq -r '.ARTIFACT_SHA1')

echo -e "
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore ${repositoryBasePath}/${signingPath}/keystore.jks -storepass ${STORE_PASSWORD} -keypass ${KEY_PASSWORD} -signedjar ${signedUnalignedArtifactPath} ${artifactPath} ${KEY_ALIAS}
" '$(find /usr/local/android-sdk/build-tools/ -name zipalign|sort|tail -n1)' " -v -p 4 ${signedUnalignedArtifactPath} ${signedAlignedArtifactPath}
keytool -list -printcert -jarfile ${signedAlignedArtifactPath}
" |docker run -w "${appFolder}/" --rm -i -v "${appFolder}/":"${appFolder}/":rw -v "${appFolder}/.gradle":/root/.gradle:rw -v "${appFolder}/.gem":/root/.gem:rw "${sdkVersion}" /bin/bash

rm -rf ${repositoryBasePath}

# Restore permissions
docker run -w "${appFolder}/" --rm -t -v "${appFolder}/":"${appFolder}/":rw  -v "${appFolder}/.gradle":/root/.gradle:rw -v "${appFolder}/.gem":/root/.gem:rw "${sdkVersion}" chown -R --reference=Jenkinsfile . || exit $?

