# ci-scripts

Some CI/CD scripts.

## Introduction

[TBD]

## Install and usage

* Install git-promote gist as root https://gist.github.com/pedroamador/5b08104e0c128ee4e97acf15dd1f90db

* Add the repository as submodule of your script in the directory ci-scripts/common

```
$ git submodule add https://github.com/pedroamador/ci-scripts ci-scripts/common
```

* Install ci-script stuff into your locally "versioned" ci-scripts/bin folder using one target

### For Android development

```
$ ci-scripts/common/bin/install.sh android
Installing Android ci-scripts stuff
ci-scripts/common/templates/android/bin/ci-scripts_caller.sh.dist -> ci-scripts/bin/buildApk.sh
ci-scripts/common/templates/android/DeclarativePipeline.Jenkinsfile -> Jenkinsfile
ci-scripts/common/templates/android/sonar-project.properties -> sonar-project.properties
ci-scripts/common/templates/android/Gemfile -> Gemfile
ci-scripts/common/templates/android/Gemfile.lock -> Gemfile.lock
ci-scripts/common/templates/android/fastlane/Appfile -> fastlane/Appfile
ci-scripts/common/templates/android/fastlane/Fastfile -> fastlane/Fastfile
ci-scripts/common/templates/android/fastlane/Pluginfile -> fastlane/Pluginfile
ci-scripts/common/templates/android/fastlane/README.md -> fastlane/README.md
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

### For Cucumber automated test

```
$ ci-scripts/common/bin/install.sh cucumber
Installing cucumber ci-scriptss stuff

----------Info----------
=======BDDfire is creating 'cucumber' framework. Please have a look which files are being created============
---------------------------

[...]

----------Thanks for installing Cucumber functional test framework !----------
=====BDDfire recommend you to install LOAD and Accessibility Frameworks as well====== 
=====Just Run 'bddfire fire_load' and 'bddfire fire_accessibility' command now====== 
---------------------------
ci-scripts/common/templates/cucumber/Dockerfile -> ci-scripts/test/cucumber/Dockerfile
ci-scripts/common/templates/cucumber/docker.sh -> ci-scripts/test/cucumber/docker.sh
ci-scripts/common/templates/cucumber/features/step_definitions/bddfire_steps.rb -> ci-scripts/test/cucumber/features/step_definitions/bddfire_steps.rb
ci-scripts/common/templates/cucumber/features/support/hooks.rb -> ci-scripts/test/cucumber/features/support/hooks.rb
ci-scripts/common/templates/cucumber/config.yml.dist -> ci-scripts/test/cucumber/config.yml.dist


Install of ci-scripts stuff finished

Next steps:
- Do a 'bundle install' on the directory ci-scripts/test/cucumber
- Change CONTAINER_NAME variable in ci-scripts/test/cucumber/docker.sh
- Edit content of ci-scripts/test/cucumber/config.yml.dist and copy it to ci-scripts/test/cucumber/config.yml
```


The following file are added from templates to your repository:

```
MacBook-Air-de-Infrastructure:mytest pedro.amador$ find ci-scripts/test/
ci-scripts/test/
ci-scripts/test//cucumber
ci-scripts/test//cucumber/.relish
ci-scripts/test//cucumber/.rubocop.yml
ci-scripts/test//cucumber/.yard.yml
ci-scripts/test//cucumber/browser.json
ci-scripts/test//cucumber/config.yml.dist
ci-scripts/test//cucumber/cucumber.yml
ci-scripts/test//cucumber/docker.sh
ci-scripts/test//cucumber/Dockerfile
ci-scripts/test//cucumber/features
ci-scripts/test//cucumber/features/api.feature
ci-scripts/test//cucumber/features/bddfire.feature
ci-scripts/test//cucumber/features/pages
ci-scripts/test//cucumber/features/pages/HomePage.rb
ci-scripts/test//cucumber/features/step_definitions
ci-scripts/test//cucumber/features/step_definitions/bddfire_steps.rb
ci-scripts/test//cucumber/features/support
ci-scripts/test//cucumber/features/support/env.rb
ci-scripts/test//cucumber/features/support/hooks.rb
ci-scripts/test//cucumber/Gemfile
ci-scripts/test//cucumber/Gemfile-raw
ci-scripts/test//cucumber/package.json
ci-scripts/test//cucumber/Rakefile
ci-scripts/test//cucumber/README.md
ci-scripts/test//cucumber/script
ci-scripts/test//cucumber/script/accessibility
ci-scripts/test//cucumber/script/ci_script
ci-scripts/test//cucumber/script/load
ci-scripts/test//cucumber/script/run_appium
```

## Android target

Useful ci stuff for Android developments.

You can:

* Build docker images with specific SDK version, with "all-in" (Android SDK, Android Build tools, Fastlane). For now we have:
  * 21.1.2
  * 22.0.1
  * 23.0.1
  * 23.0.2
  * 23.0.3
  * 25.0.0
  * 25.0.2
* Build APK's of your app with the docker image you choose using gradlew or Fastlane.

### buildApk.sh

Build your android APK using docker.

Examples:

```
$ ci-scripts/common/bin/buildApk.sh --sdkVersion=25.0.2 --gradlewArguments="clean assembleDebug"
[...]
```

Then the script will do the folloging:

* Build a docker image, if don't exists, called "ci-scripts:25.0.2", using the Dockerfile located in ci-scripts/common/docker/android-sdk-25.0.2 folder.
* Run the gradlew task "clean assembleDebug" in a docker container with the "ci-scripts:25.0.2" image base builded in the previous step.

```
$ ci-scripts/common/bin/buildApk.sh --sdkVersion="mydocker" --lane="debug"
[...]
```

Then the script will do the folloging:
* Build a docker image, if don't exists, called "customimage", using the Dockerfile located in ci-scripts/docker/customimage folder.
* Use Fastlane with "debug" lane to build the APK in a docker container with the "customimage" image base builded in the previous step.

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
1. Use 'docker' labeled node.
2. Stage condicional: this stage is launched only in the 'develop' branch.
3. Checkout the principal code repository using SCM plugin.
4. Initialize and update all of the submodules, including this "ci-scrits/common".
5. Build the APK with a container based on ci-scripts:25.0.2 docker image, using 25.0.2 build tools + Android sdk 25, and execute the lane "debug".
6. Archive all of the resultant APK files as artifacts of the jenkins build job.

## Cucumber automated test target

Useful ci stuff for cucumber web automated testing. There is based on the "bddfire" github project https://github.com/Shashikant86/bddfire so maybe you should read the docs of this project

After install ci-script stuff, you should:

### Install vendors

Go to ci-scripts/test/cucumber folder and exec 'bundle install' within. This install bddfire vendors, required in cucumber runs

### Modify config file

Change config values in ci-scripts/test/cucumber/config.yml.dist file. There is the original content

```
$ cat ci-scripts/test/cucumber/config.yml.dist 
baseurl: https://www.google.es

take_screenshots: true
screenshot_delay: 1
browser_width:    1024
```

There is an explanation of the config variables:
* baseurl           Referes to url used in some test functions, like "navigate_to".
* take_screenshots  Set to "true" if you want to save a screenshot on evety test step. The screenshots are located into "ci-scripts/test/cucumber/reports" directory
* screenshot_delay  How many seconds the test will wait for navigator before take screenshot
* browser_width     Using poltergeist, width of the viewport in pixels

Once the config is finished, copy the "config.yml.dist" file to non-versioned one "config.yml" in the same directory

### Change CONTAINER_NAME variable in ci-scripts/test/cucumber/docker.sh

The aim of this action is to have different container names, one for each project you run on the same Jenkins service (or equivalent continuous integration service)

After do this three tasks, you can run the default example feature by executing "rake chrome" or "rake poltergeist" in the ci-scripts/test/cucumber directory:

```
$ rake poltergeist
/usr/local/Cellar/ruby/2.4.1_1/bin/ruby -S bundle exec cucumber features -p poltergeist --format pretty --profile html -t ~@api
DEPRECATED: #default_wait_time= is deprecated, please use #default_max_wait_time= instead
{"baseurl"=>"https://www.google.es", "take_screenshots"=>true, "screenshot_delay"=>1, "browser_width"=>1024}
Using the poltergeist and html profiles...
Feature: Google Search to explore BDDfire

  Scenario: View home page                     # features/bddfire.feature:4
    Given I am on "http://www.google.com"      # bddfire-2.0.8/lib/bddfire/web/web_steps.rb:2
    When I fill in "q" with the text "bddfire" # bddfire-2.0.8/lib/bddfire/web/web_steps.rb:6
    Then I should see "Sign in"                # bddfire-2.0.8/lib/bddfire/web/web_steps.rb:10
      expected to find text "Sign in" in "Google+ Búsqueda Imágenes Maps Play YouTube Noticias Gmail Más Iniciar sesión España Búsqueda avanzada Herramientas del idioma Google.es también en: català galego euskara English Programas de publicidadSoluciones Empresariales+GoogleTodo acerca de GoogleGoogle.com © 2017 - Privacidad - Condiciones" (RSpec::Expectations::ExpectationNotMetError)
      features/bddfire.feature:7:in `Then I should see "Sign in"'

Failing Scenarios:
cucumber -p poltergeist -p html features/bddfire.feature:4 # Scenario: View home page

1 scenario (1 failed)
3 steps (1 failed, 2 passed)
1m4.210s
```

There is the feature of this test

```
$ cat ci-scripts/test/cucumber/features/bddfire.feature 
Feature: Google Search to explore BDDfire


Scenario: View home page
  Given I am on "http://www.google.com"
  When I fill in "q" with the text "bddfire"
  Then I should see "Sign in"
```

In this case, the test fails beacause the google site get spanish localization, and the "Sing in" text is "Iniciar sesión".

You can see the result screenshots at ci-scripts/test/cucumber/reports in with the name style "screenshot_20170809085334_1.png"

The same test runs into docker. Test it executing "./docker.sh" in the ci-scripts/test/cucumber directory. You need docker up and running on your workstation. By executing the docker.sh script the contents of ci-scripts/test/cucumber/reports directore is wiped, take care of this.

