#!/bin/bash

buildApk="$(basename "$0" | sed -e 's/-/ /')"
HELP="Usage: $buildApk [options...]

Build docker image with Android SDK tools xx.y.z and fastlane installed on it

Options:
  --sdkVersion=xx.y.z                       # use sdk version xx.y.z (mandatory)
  --lane='lane_name'                        # use fastlane with lane 'lane_name'
                                            # Can't use with '--gradlewArguments'
  --gradlewArguments='gradlew arguments'    # build with gradle, using arguments 'gradlew arguments'
                                            # Can't use with '--lane'
  --help                                    # prints this

Examples:
  $buildDockerIMage --sdkVersion=23.0.3 --gradlewArguments='clean assembleBuile'  # build using gradle
  $buildDockerIMage --sdkVersion=23.0.3 --lane='debug'                            # build using fastlane
"

cd "$(dirname $0)/.."
ciRootFolder="$(pwd)"
cd "../.."
appFolder=$(pwd)

# Parse variables
gradlewArguments=""
lane=""
sdkversion=""
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
    --h|\?|--help)
      echo "$HELP"
      exit 0
      ;;
    *)
      printf "[ERROR] Invalid argument '$1 '\n"
      echo "$HELP"
      exit 0
  esac
  shift
done

# Build docker image
if [ "$sdkVersion" == "" ]
then
  echo "[ERORR]: you must specify --sdkVersion option"
  echo
  echo "$HELP"
  exit 1
fi

if [ "$lane" != "" ]
then
  if [ "$gradlewArguments" != "" ]
  then
    echo "[ERROR]: Can't use --gradlewArguments and --lane'"
    echo
    echo "$HELP"
    exit 1
  fi
  # Execute lane
  docker run --rm -t -v "${appFolder}/":/myApp:rw android-sdk:${sdkVersion} fastlane ${lane}
  rv=$?
else
  if [ "$gradlewArguments" != "" ]
  then
    # Execute gradlew task
    docker run --rm -t -v "${appFolder}/":/myApp:rw android-sdk:${sdkVersion} ./gradlew ${gradlewArguments}
  else
    echo "[ERROR]: you must specify --lane or --gradlewArguments option"
    echo
    echo "$HELP"
    exit 1
  fi
fi
"${ciRootFolder}/bin/buildDockerImage.sh" --sdkVersion=$sdkVersion
rv=$?


# Restore permissions
docker run --rm -t -v "${appFolder}/":/myApp:rw android-sdk:${sdkVersion} chown -R --reference=gradlew . || exit $?

exit ${rv}
