# ci-scripts

Some CI/CD scripts

Usage:

* Add the repository as submodule of your script

    $ git submodule add https://github.com/pedroamador/ci-scripts ci-scripts 

The project add some develop and CI/CD common task to you project

## Android

You can:
* Build docker images with specific SDK version. For now we have:
  * 23.0.1
  * 23.0.2
  * 23.0.3
* Build APK's of your app with the docker image you choose

There is a script on the "android" folder called "buildApk.sh". You can build your apk using docker.
Example:

    $ ci-scripts/buildApk.sh --sdkVersion=23.0.3 --gradlewArguments="clean assembleDebug"

Then the script will do the follogint:
* Build a docker image claled "android-23.0.3", using the Dockerfile located in ci-scripts/docker/android-23.0.3 folder.
* Run the gradlew task "clean assembleDebug" in a docker container with the "android-23.0.3" image base builded in the previous step. 

The script uses the debug.keystore located in the ".android" folder of your home.

You can run the script from the jenkins pipeline your CI / CD project like in this example:

    $ cat Jenkinsfile
    #!groovy

    [...]

    node {
        // Local checkout
        checkout scm // 1)
        sh 'git submodule update --init' // 2)

        // 
        stage('Build APK') {
            sh 'ci-scripts/android/buildApk.sh --sdkVersion=23.0.3 --gradlewArguments="clean assembleDebug"' // 3)
            archiveArtifacts artifacts: '**/apk/*-debug.apk', fingerprint: true // 4)
        }

        [...]

    }

    [...]

You must have a "debug.keystore" in the ~/.android folder of the jenkins user.

An explanation of the interesting points marked above:
1) Checkout the principal code reporitory using SCM plugin
2) Initialize and update all of the submodules, including this "ci-scrits"
3) Build the APK, using 23.0.3 sdk version, builded with "./gradlew clean assembleDebug"
4) Archive all of the resultant APK as artifacts of the jenkins build job
