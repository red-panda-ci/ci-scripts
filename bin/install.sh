#!/bin/bash
cd $(dirname $0)
mkdir -p ../../bin
mkdir ../../../fastlane
echo "Install script wrappers:"
cp -pvn ci-scripts_caller.sh.dist ../../bin/buildApk.sh
cp -pvn ../templates/DeclarativePipeline.Jenkinsfile ../../../Jenkinsfile
cp -pvn ../templates/sonar-project.properties ../../../sonar-project.properties
cp -pvn ../templates/Gemfile ../../../Gemfile
cp -pvn ../templates/Gemfile.lock ../../../Gemfile.lock
for filename in Appfile Fastfile Pluginfile README.md
do
    cp -pvn ../templates/fastlane/${filename} ../../../fastlane/${filename}
done
