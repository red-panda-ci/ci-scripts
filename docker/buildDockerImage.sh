#!/bin/bash

cd "$(dirname $0)"

# Parse variables
echo -n "Parsing arguments..."
sdkversion=""
while [ $# -gt 0 ]; do
  case "$1" in
    --sdkVersion=*)
      sdkVersion="${1#*=}"
      ;;
    *)
      printf " [ERROR] Invalid argument '$1 '\n"
      exit 1
  esac
  shift
done
echo "done"

# Check sdk version
case "${sdkVersion}" in
    "23.0.3")
        dockerImageName="android-${sdkVersion}"
        ;;
    *)
        echo "Unknown SDK version: ${sdkVersion}"
        cat << EOF

Available SDK:
* 23.0.3
EOF

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
buildTempFolder=/tmp/ci-scripts.${dockerImageName}.${RANDOM}
mkdir -p ${buildTempFolder}/tools || exit 1
cp tools/* ${buildTempFolder}/tools || exit 2
cp ${dockerImageName}/Dockerfile ${buildTempFolder} || exit 3
cp ~/.android/debug.keystore ${buildTempFolder} || exit 4

# Docker image build (container image files involved)
docker build -t ${dockerImageName} ${buildTempFolder}

# Remove temporary resources
rm ${buildTempFolder}/tools/* ${buildTempFolder}/Dockerfile ${buildTempFolder}/debug.keystore || exit 5
rmdir ${buildTempFolder}/tools ${buildTempFolder}|| exit 6
