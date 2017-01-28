# ci-scripts

Some CI/CD scripts

Usage:
- Add the repository as submodule of your script

    $ git submodule add https://github.com/pedroamador/ci-scripts ci-scripts 

The project add some develop and CI/CD common task to you project

## Android

You can:
* Build docker images with specific SDK version
** 23.0.3
* Build APK's of your app with the docker image you choose

There is a script on the "android" folder called "buildApk.sh". You can build your apk using docker.
Example:

    $ ci-scripts/buildApk.sh --sdkVersion=23.0.3 --gradlewArguments="clean assembleDebug"

Then the script will do the follogint:
- Build a docker image claled "android-23.0.3", using the Dockerfile located in ci-scripts/docker/android-23.0.3 folder.
- Run the gradlew task "clean assembleDebug" in a docker container with the "android-23.0.3" image base builded in the previous step. 

The script uses the debug.keystore located in the ".android" folder of your home.

You can run the script from the jenkins pipeline your CI / CD project like this:

    $ cat Jenkinsfile

    [...]

    node {
        step ('Build APK') {
            sh 'ci-scripts/android/buildApk --sdkVersion=23.0.3 --gradlewArguments="clean assembleDegub"'
        }
    }

In this case you must have a "debug.keystore" in the ~/.android folder of the jenkins user
