#!/bin/bash
cd $(dirname $0)
mkdir -p ../../bin
echo "Install script wrappers:"
cp -pvn ci-scripts_caller.sh.dist ../../bin/buildApk.sh
cp -pvn ../templates/DeclarativePipeline.Jenkinsfile ../../../Jenkinsfile
cp -pvh ../templates/sonar-project.properties ../../../sonar-project.properties
