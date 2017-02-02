#!/bin/bash

buildApk="$(basename "$0" | sed -e 's/-/ /')"
HELP="Usage: $buildApk --sdkVersion=xx.y.z --gradlewArguments='clean assembleBuild'

Build docker image with Android SDK tools xx.y.z and fastlane installed on it

Options:
  --sdk-version=xx.y.z        # use sdk version xx.y.z
  --gradlewArguments='...'    # use gradlew arguments '...'
  --help                      # prints this

Examples:
  $buildDockerIMage --sdkVersion=23.0.3 --gradlewArguments='clean assembleBuile'
"

cd "$(dirname $0)/.."
ciRootFolder="$(pwd)"
cd "../.."
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
    --h|\?|--help)
      echo "$HELP"
      exit 0
      ;;
    *)
      printf " [ERROR] Invalid argument '$1 '\n"
      echo "$HELP"
      exit 0
  esac
  shift
done

# Build docker image
"${ciRootFolder}/bin/buildDockerImage.sh" --sdkVersion=$sdkVersion || exit $?

# Execute gradlew task
docker run --rm -t -v "${appFolder}/":/myApp:rw android-sdk:${sdkVersion} ./gradlew ${gradlewArguments} || exit $?

# Restore permissions
docker run --rm -t -v "${appFolder}/":/myApp:rw android-sdk:${sdkVersion} chown -R --reference=gradlew . || exit $?
