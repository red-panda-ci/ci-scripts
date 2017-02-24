#!/bin/bash

buildDockerImage="$(basename "$0" | sed -e 's/-/ /')"
HELP="Usage: $buildDockerImage --sdkVersion=xx.y.z

Build docker image with Android SDK tools xx.y.z and fastlane installed on it

Options:
  --sdkVersion=xx.y.z         # build docker image called 'android-sdk:xx.y.z'
  --help                      # prints this

Examples:
  $buildDockerIMage 23.0.3        # Build docer image called 'android-sdk:23.0.3'
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
case "${sdkVersion}" in
    "22.0.1")
        dockerImageName="android-sdk:${sdkVersion}"
        dockerImageFolder="android-sdk-${sdkVersion}"
        ;;
    "23.0.1")
        dockerImageName="android-sdk:${sdkVersion}"
        dockerImageFolder="android-sdk-${sdkVersion}"
        ;;
    "23.0.2")
        dockerImageName="android-sdk:${sdkVersion}"
        dockerImageFolder="android-sdk-${sdkVersion}"
        ;;
    "23.0.3")
        dockerImageName="android-sdk:${sdkVersion}"
        dockerImageFolder="android-sdk-${sdkVersion}"
        ;;
    "25.0.2")
        dockerImageName="android-sdk:${sdkVersion}"
        dockerImageFolder="android-sdk-${sdkVersion}"
        ;;
    *)
        echo "Unknown SDK version: ${sdkVersion}"
        echo
        echo "$HELP"
        exit 1
        ;;
esac

# Check user home debug.keystore
echo -n "~/.android/debug.keystore "
if [ -f ~/.android/debug.keystore ]
then
    echo "found"
else
    echo "not found. Can't continue"
    exit 1
fi

# Prepare temporary resources
buildTempFolder=/tmp/ci-scripts.${dockerImageFolder}.${RANDOM}
mkdir -p ${buildTempFolder}/tools || exit 1
cp tools/* ${buildTempFolder}/tools || exit 2
cp ${dockerImageFolder}/Dockerfile ${buildTempFolder} || exit 3
cp ~/.android/debug.keystore ${buildTempFolder} || exit 4

# Docker image build (container image files involved)
docker build -t ${dockerImageName} ${buildTempFolder}

# Remove temporary resources
rm ${buildTempFolder}/tools/* ${buildTempFolder}/Dockerfile ${buildTempFolder}/debug.keystore || exit 5
rmdir ${buildTempFolder}/tools ${buildTempFolder}|| exit 6
