# ci-scripts

## Introduction

Some CI/CD scripts

[TBD]

## Install and usage

* Install git-promote gist as root https://gist.github.com/pedroamador/5b08104e0c128ee4e97acf15dd1f90db

* Add the repository as submodule of your script

    $ git submodule add https://github.com/pedroamador/ci-scripts ci-scripts/common

* Install script wrappers into your "versioned" ci-scripts/bin directory

    $ ci-scripts/common/bin/install.sh
    Install script wrappers:
    ci-scripts_caller.sh.dist -> ../../bin/buildApk.sh

The script add some develop and CI/CD common task to you project

You can:
* Build APK's of your app with the docker image you choose
* Build docker images with specific SDK version. For now we have:
  * 22.0.1
  * 23.0.1
  * 23.0.2
  * 23.0.3

There are some script wrapper under your "ci-scripts/bin" directory:

### buildApk.sh

Build your android APK using docker.

Examples:

    $ ci-scripts/common/bin/buildApk.sh --sdkVersion=23.0.3 --gradlewArguments="clean assembleDebug"
    [...]

Then the script will do the follogint:
* Build a docker image, if don't exists, called "android-23.0.3", using the Dockerfile located in ci-scripts/common/docker/android-23.0.3 folder.
* Run the gradlew task "clean assembleDebug" in a docker container with the "android-23.0.3" image base builded in the previous step

    $ ci-scripts/common/bin/buildApk.sh --sdkVersion=22.0.1 --lane="debug"
    [...]

Then the script will do the follogint:
* Build a docker image, if don't exists, called "android-22.0.1", using the Dockerfile located in ci-scripts/common/docker/android-23.0.3 folder.
* Run the gradlew task "fatlane debug" in a docker container with the "android-22.0.1" image base builded in the previous step.


The script uses the debug.keystore located in the ".android" folder of your home.

You can run the script from the Jenkins pipeline of your CI / CD project like this:

    $ cat Jenkinsfile
    #!groovy

    [...]

    node {
        // Local checkout
        checkout scm // 1)
        sh 'git submodule update --init' // 2)

        // 
        stage('Build APK') {
            sh 'ci-scripts/common/bin/buildApk.sh --sdkVersion=23.0.3 --lane="debug"' // 3)
            archiveArtifacts artifacts: '**/apk/*-debug.apk', fingerprint: true // 4)
        }

        [...]

    }

    [...]

You must have a "debug.keystore" in the ~/.android folder of the jenkins user.

An explanation of the interesting points marked above:
1. Checkout the principal code reporitory using SCM plugin
2. Initialize and update all of the submodules, including this "ci-scrits/common"
3. Build the APK with a container based on android-23.0.3 docker image, using 23.0.3 sdk version, and execute the lane "debug"
4. Archive all of the resultant APK files as artifacts of the jenkins build job
