# ci-scripts

Some CI/CD scripts

## Introduction

[TBD]

## Install and usage

* Install git-promote gist as root https://gist.github.com/pedroamador/5b08104e0c128ee4e97acf15dd1f90db

* Add the repository as submodule of your script

```
$ git submodule add https://github.com/pedroamador/ci-scripts ci-scripts/common
```

* Install script wrappers into your locally "versioned" ci-scripts/bin folder

```
$ ci-scripts/common/bin/install.sh 
Install script wrappers:
ci-scripts_caller.sh.dist -> ../../bin/buildApk.sh
../templates/DeclarativePipeline.Jenkinsfile -> ../../../Jenkinsfile
../templates/sonar-project.properties -> ../../../sonar-project.properties
../templates/Gemfile -> ../../../Gemfile
../templates/Gemfile.lock -> ../../../Gemfile.lock
../templates/fastlane/Appfile -> ../../../fastlane/Appfile
../templates/fastlane/Fastfile -> ../../../fastlane/Fastfile
../templates/fastlane/Pluginfile -> ../../../fastlane/Pluginfile
../templates/fastlane/README.md -> ../../../fastlane/README.md
```

The following file are added from templates to your repository:

```
ci-scripts/bin/buildApk.sh
Jenkinsfile
sonar-project.properties
Gemfile
Gemfile.lock
fastlane/Appfile
fastlane/Fastfile
fastlane/Pluginfile
fastlane/README.md
```

You can:

* Build docker images with specific SDK version, with "all-in" (Android SDK, Android Build tools, Fastlane). For now we have:
  * 22.0.1
  * 23.0.1
  * 23.0.2
  * 23.0.3
  * 25.0.0
  * 25.0.2
* Build APK's of your app with the docker image you choose using gradlew or Fastlane

### buildApk.sh

Build your android APK using docker.

Examples:

```
$ ci-scripts/common/bin/buildApk.sh --sdkVersion=23.0.3 --gradlewArguments="clean assembleDebug"
[...]
```

Then the script will do the folloging:

* Build a docker image, if don't exists, called "ci-scripts:23.0.3", using the Dockerfile located in ci-scripts/common/docker/ci-scripts:23.0.3 folder.
* Run the gradlew task "clean assembleDebug" in a docker container with the "ci-scripts:23.0.3" image base builded in the previous step

```
$ ci-scripts/common/bin/buildApk.sh --sdkVersion=22.0.1 --lane="debug"
[...]
```

Then the script will do the folloging:
* Build a docker image, if don't exists, called "ci-scripts:25.0.2", using the Dockerfile located in ci-scripts/common/docker/ci-scripts:25.0.2 folder.
* Run the gradlew task "fatlane debug" in a docker container with the "ci-scripts:25.0.2" image base builded in the previous step.

The script uses the debug.keystore located in the ".android" folder of your home.

You can run the script from the Jenkins pipeline of your CI / CD project like this:

```
$ cat Jenkinsfile
#!groovy

@Library('github.com/pedroamador/jenkins-pipeline-library') _

pipeline {
    agent none

    stages {
        stage ('Build') {
            agent { label 'docker' }                                                        # 1)
            when { branch 'develop' }                                                       # 2)
            steps  {
                checkout scm                                                                # 3)
                sh 'git submodule update --init'                                            # 4)
                sh 'ci-scripts/common/bin/buildApk.sh --sdkVersion=25.0.2 --lane="develop"' # 4)
                archive '**/*.apk'                                                          # 6)
            }
        }

    [...]

    }   

    [...]

}
```

You must have a "debug.keystore" in the ~/.android folder of the jenkins user, or under ".android" folder of your repository.

An explanation of the interesting points marked above:
1. Use 'docker' labeled node
2. Stage condicional: this stage works only with 'develop' branch
3. Checkout the principal code reporitory using SCM plugin
4. Initialize and update all of the submodules, including this "ci-scrits/common"
5. Build the APK with a container based on ci-scripts:25.0.2 docker image, using 25.0.2 build tools + Android sdk 25, and execute the lane "debug"
6. Archive all of the resultant APK files as artifacts of the jenkins build job
