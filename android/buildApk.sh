#!/bin/bash

cd "$(dirname $0)/.."
ciRootFolder="$(pwd)"
cd ".."
appFolder=$(pwd)

# Parse variables
echo -n "Parsing arguments..."
gradlewArguments=""
sdkversion=""
while [ $# -gt 0 ]; do
  case "$1" in
    --sdkVersion=*)
      sdkVersion="${1#*=}"
      ;;
    --gradlewArguments=*)
      gradlewArguments="${1#*=}"
      ;;
    *)
      printf " [ERROR] Invalid argument '$1 '\n"
      exit 1
  esac
  shift
done

# Build docker image
"${ciRootFolder}/docker/buildDockerImage.sh" --sdkVersion=$sdkVersion || exit $?

# Execute gradlew task
docker run --rm -t -v "${appFolder}/":/myApp:rw android-sdk:${sdkVersion} ./gradlew ${gradlewArguments} || exit $?

# Restore permissions
docker run --rm -t -v "${appFolder}/":/myApp:rw android-sdk:${sdkVersion} chown -R --reference=docker/Dockerfile . || exit $?
