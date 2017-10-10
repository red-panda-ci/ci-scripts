#!/bin/bash

function buildDockerImage () {
  "${ciRootFolder}/bin/buildDockerImage.sh" --sdkVersion=${sdkVersion} || exit $?
}

buildApk="$(basename "$0" | sed -e 's/-/ /')"
HELP="Usage: ${buildApk} [options...]

Build docker image with Android SDK tools xx.y.z and fastlane installed on it

Options:
  --sdkVersion=xx.y.z                       # use sdk version xx.y.z (mandatory)
  --command='bash command'                  # bash command to execute within container
                                            # Takes preference over '--lane' and '--gradlewArguments'
  --lane='lane_name'                        # use fastlane with lane 'lane_name'
                                            # Takes preference over '--gradlewArguments'
                                            # Don't work if use '--command'
  --notes='notes'                           # Notes for the buid, use it with --lane option
  --gradlewArguments='gradlew arguments'    # build with gradle, using arguments 'gradlew arguments'
                                            # Don't work if use '--lane' or '--command'
  --help                                    # prints this

Examples:
  ${buildApk} --sdkVersion=23.0.3 --gradlewArguments='clean assembleBuild'  # build using gradle
  ${buildApk} --sdkVersion=23.0.3 --lane='debug' --notes='develop RC-1'     # build using fastlane
"

cd "$(dirname "$0")/.."
ciRootFolder="$(pwd)"
cd "../.."
appFolder="$(pwd)"

# Parse variables
gradlewArguments=""
lane=""
command=""
sdkversion=""
notes=""
while [ $# -gt 0 ]; do
  case "$1" in
    --sdkVersion=*)
      sdkVersion="${1#*=}"
      ;;
    --gradlewArguments=*)
      gradlewArguments="${1#*=}"
      ;;
    --lane=*)
      lane="${1#*=}"
      ;;
    --command=*)
      command="${1#*=}"
      ;;
    --notes=*)
      notes="${1#*=}"
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

# Build docker image
if [ "${sdkVersion}" == "" ]
then
  echo "[ERORR]: you must specify --sdkVersion option"
  echo
  echo "${HELP}"
  exit 1
fi

if [ "${command}" != "" ]
then
  buildDockerImage
  # Execute bash command
  docker run --rm -t -v "${appFolder}/":/myApp:rw -v "${appFolder}/.gradle":/root/.gradle:rw -v "${appFolder}/.gem":/root/.gem:rw ci-scripts:"${sdkVersion}" bash -c "${command}"
elif [ "${lane}" != "" ]
then
  buildDockerImage
  # Execute lane
  docker run --rm -t -v "${appFolder}/":/myApp:rw -v "${appFolder}/.gradle":/root/.gradle:rw -v "${appFolder}/.gem":/root/.gem:rw ci-scripts:"${sdkVersion}" fastlane "${lane}" notes:"${notes}"
  rv=$?
else
  if [ "${gradlewArguments}" != "" ]
  then
    buildDockerImage
    # Execute gradlew task
    docker run --rm -t -v "${appFolder}/":/myApp:rw -v "${appFolder}/.gradle":/root/.gradle:rw -v "${appFolder}/.gem":/root/.gem:rw ci-scripts:"${sdkVersion}" ./gradlew ${gradlewArguments}
    rv=$?
  else
    echo "[ERROR]: you must specify --command, --lane or --gradlewArguments option"
    echo
    echo "${HELP}"
    exit 1
  fi
fi

# Restore permissions
docker run --rm -t -v "${appFolder}/":/myApp:rw  -v "${appFolder}/.gradle":/root/.gradle:rw -v "${appFolder}/.gem":/root/.gem:rw ci-scripts:"${sdkVersion}" chown -R --reference=Jenkinsfile . || exit $?

exit ${rv}
