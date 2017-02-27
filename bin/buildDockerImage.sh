#!/bin/bash

buildDockerImage="$(basename "$0" | sed -e 's/-/ /')"
HELP="Usage: $buildDockerImage --sdkVersion=xx.y.z

Build docker image with Android SDK tools xx.y.z and fastlane installed on it

Options:
  --sdkVersion=xx.y.z         # build docker image called 'ci-scripts:xx.y.z'
  --help                      # prints this

Examples:
  $buildDockerIMage 23.0.3        # Build docer image called 'ci-scripts:23.0.3'
"

cd "$(dirname $0)/../docker"

# Parse variables
sdkversion=""
echo $1
while [ $# -gt 0 ]; do
  case "$1" in
    --sdkVersion=*)
      sdkVersion="${1#*=}"
      ;;
    --h|\?|--help)
      echo "$HELP"
      exit 0
      ;;
    *)
      printf 'ERROR: Unknown option: %s\n' "$1" >&2
      echo "$HELP"
      exit 1
  esac
  shift
done

# Check sdk version
if [ -f android-sdk-${sdkVersion}/Dockerfile ]
then
    dockerImageName="ci-scripts:${sdkVersion}"
    dockerImageFolder="android-sdk-${sdkVersion}"
else
    if [ -f ../../docker/${sdkVersion}/Dockerfile ]
    then
        dockerImageName="ci-scripts:${sdkVersion}"
        dockerImageFolder="../../docker/${sdkVersion}"
    else
        echo "Unknown SDK version: ${sdkVersion}"
        echo
        echo "$HELP"
        exit 1
    fi
fi

echo "Docker image name: $dockerImageName"
echo "Docker image folder: $dockerImageFolder"

# Check user home debug.keystore
echo -n "Searching for .android/debug.keystore file..."
if [ -f ../../../.android/debug.keystore ]
then
    androidFolder="../../../.android"
    echo " found in project. Use '.android' of root project folder"
else
    if [ -f ~/.android/debug.keystore ]
    then
        androidFolder="~/.android"
        echo " found global. Use global '~/.android' of the user home folder"
    else
        echo " not found. Can't continue"
        exit 1
    fi
fi

# Prepare temporary resources
buildTempFolder=/tmp/ci-scripts.${dockerImageFolder}.${RANDOM}
mkdir -p ${buildTempFolder}/tools ${buildTempFolder}/.android || exit 1
cp tools/* ${buildTempFolder}/tools || exit 2
cp ${dockerImageFolder}/Dockerfile ${buildTempFolder} || exit 3
cp ${androidFolder}/* ${buildTempFolder}/.android/ || exit 4

# Docker image build (container image files involved)
docker build -t ${dockerImageName} ${buildTempFolder}

# Remove temporary resources
rm ${buildTempFolder}/tools/* ${buildTempFolder}/.android/* ${buildTempFolder}/Dockerfile || exit 5
rmdir ${buildTempFolder}/tools ${buildTempFolder}/.android ${buildTempFolder}|| exit 6
