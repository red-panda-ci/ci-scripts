#!/bin/bash
# POSIX

function check_commands {
    # Check commands
    COMMAND_LIST=$1
    EXIT_CODE=0

    # Check required commands
    for COMMAND in $COMMAND_LIST
    do
        command -v $COMMAND >/dev/null || EXIT_CODE=1
    done

    if [[ $EXIT_CODE -eq 1 ]]
    then
        echo "\n${install} requires '${COMMAND}' command but is not installed" >&2
        echo "\nExecution aborted\n" >&2
        echo
        exit 1
    fi
}

function cucumber_install {
    check_commands "ruby rake bundle cucumber bddfire"
    echo "Installing cucumber ci-scriptss stuff"
    [ -e ci-scripts/test/cucumber ] && echo "Already installed ci-scripts stuff into ci-scripts/test/cucumber. Exiting now" && exit
    cd $(dirname $0)/../../..
    mkdir -p ci-scripts/test
    cd ci-scripts/test
    bddfire fire_cucumber
    cd ../..
    cp -pv ci-scripts/common/templates/cucumber/Dockerfile                                 ci-scripts/test/cucumber/Dockerfile
    cp -pv ci-scripts/common/templates/cucumber/docker.sh                                  ci-scripts/test/cucumber/docker.sh
    cp -pv ci-scripts/common/templates/cucumber/features/step_definitions/bddfire_steps.rb ci-scripts/test/cucumber/features/step_definitions/bddfire_steps.rb
    cp -pv ci-scripts/common/templates/cucumber/features/support/hooks.rb                  ci-scripts/test/cucumber/features/support/hooks.rb
    cp -pv ci-scripts/common/templates/cucumber/config.yml.dist                            ci-scripts/test/cucumber/config.yml.dist
    echo "# ci-scripts
/ci-scripts/test/cucumber/reports/*
/ci-scripts/test/cucumber/vendor
/ci-scripts/test/cucumber/config.yml
/ci-scripts/test/cucumber/node_modules" >> .gitignore
    echo "

Install of ci-scripts stuff finished

Next steps:
- Do a 'bundle install' on the directory ci-scripts/test/cucumber
- Change CONTAINER_NAME variable in ci-scripts/test/cucumber/docker.sh
- Edit content of ci-scripts/test/cucumber/config.yml.dist and copy it to ci-scripts/test/cucumber/config.yml
"
}

install="$(basename "$0" | sed -e 's/-/ /')"
HELP="Usage: $install [options...] [target]

Install ci-scripts stuff agour specific target

Target is one of these:

* android

  [tbd]  

* cucumber

  Add cucumber scripts based on bddfire project https://github.com/Shashikant86/bddfire


Options:
  --help                      # prints this

Examples:
  $install android    # install ci-scripts stuff for android target
  $install cucumber   # install ci-scripts stuff for automated web cucumber test target
"

function android_install {
    echo "Installing Android ci-scripts stuff"
    cd $(dirname $0)/../../..
    mkdir -p ci-scripts/bin
    mkdir fastlane
    cp -pvn ci-scripts/common/templates/android/bin/ci-scripts_caller.sh.dist   ci-scripts/bin/buildApk.sh
    cp -pvn ci-scripts/common/templates/android/DeclarativePipeline.Jenkinsfile Jenkinsfile
    cp -pvn ci-scripts/common/templates/android/sonar-project.properties        sonar-project.properties
    cp -pvn ci-scripts/common/templates/android/Gemfile                         Gemfile
    cp -pvn ci-scripts/common/templates/android/Gemfile.lock                    Gemfile.lock
    for filename in Appfile Fastfile Pluginfile README.md
    do
        cp -pvn ci-scripts/common/templates/android/fastlane/${filename} fastlane/${filename}
    done
}

target=''
while :; do
  case $1 in
    -h|\?|--help)
      echo "$HELP"
      exit 0
      ;;
    --)              # End of all options.
      shift
      break
      ;;
    -?*)
      printf 'WARN: Unknown option: %s\n' "$1" >&2
      echo "$HELP"
      exit 1
      ;;
    *)  # Default case: If no more options then break out of the loop.
      break
  esac
  shift
done

case "$#" in
  0)
    printf 'WARN: You should specify [target] as argument ' >&2
    echo "$HELP"
    exit 1
    ;;
  1)
    if [[ $1 == 'android' || $1 == 'cucumber' ]]
    then
        target=$1
    else
        printf 'WARN: unknown [target] ' >&2
        echo "$HELP"
        exit 1
    fi 
    ;;    
  *)
    echo "$HELP" >&2
    exit 1
    ;;
esac

case "$target" in
  "android")
    android_install
    ;;
  "cucumber")
    cucumber_install
    ;;
esac
exit 0

# vim: set expandtab ts=2 sw=2
