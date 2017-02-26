#!groovy

// Configurables
def sdkVersion = "23.0.3"
def gitPromote = "wget -O - https://raw.githubusercontent.com/pedroamador/git-promote/master/git-promote | bash -s -- "
def to = emailextrecipients([[$class: 'DevelopersRecipientProvider'],[$class: 'CulpritsRecipientProvider'],[$class: 'UpstreamComitterRecipientProvider'],[$class: 'FirstFailingBuildSuspectsRecipientProvider'],[$class: 'FailingTestSuspectsRecipientProvider']])
def lane = (env.BRANCH_NAME in ['develop','quality','master'] ? env.BRANCH_NAME : 'develop')

try {
    // Only pull in known branches
    stage('Build') {
        if ((env.BRANCH_NAME in ['develop','quality','master']) || env.BRANCH_NAME.startsWith('PR-')) {
            node('docker') {
                wrap([$class: 'AnsiColorBuildWrapper']) {
                    checkout scm
                    sh 'git submodule update --init'
                    sh 'ci-scripts/common/bin/buildApk.sh --sdkVersion=' + sdkVersion + ' --lane="' + lane + '"'
                    archiveArtifacts artifacts: '**/*.apk', fingerprint: true
                }
            }
        }
    }
    stage('Sonarqube Analysis') {
        if ((env.BRANCH_NAME == 'develop') || env.BRANCH_NAME.startsWith('PR-')) {
            node('docker') {
                wrap([$class: 'AnsiColorBuildWrapper']) {
                    def sonarHome = tool 'SonarQube Scanner 2.8';
                    withSonarQubeEnv('SonarQube') {
                            sh "${sonarHome}/bin/sonar-scanner"
                    }
                }
            }
        }
    }
    stage ("Promote to quality") {
        if (env.BRANCH_NAME.startsWith("release")) {
            node ('master') {
                item = env.BRANCH_NAME.split("/")
                tag = item[1]
                checkout scm
                sh 'git submodule update --init'
                sh "${gitPromote} -m 'Merge from ${env.BRANCH_NAME} with Jenkins' ${env.BRANCH_NAME} quality"
                if (env.BRANCH_NAME.startsWith("release")) {
                    build job: 'quality'
                }
            }
        }
    }
    stage ("Confirm UAT") {
        if (env.BRANCH_NAME.startsWith("release")) {
            timeout(time:5, unit:'DAYS') {
                input message: "Waiting for UAT - Build release?"
            }
        }
    }
    stage ("Promote to master") {
        if (env.BRANCH_NAME.startsWith("release")) {
            node ('master') {
                sh "${gitPromote} -m 'Merge from quality with Jenkins' quality master"
                build job: 'quality'
            }
        }
    }
    stage ("Confirm Release") {
        if (env.BRANCH_NAME.startsWith("release")) {
            timeout(time:5, unit:'DAYS') {
                input message: 'Waiting for approval - Upload to Play Store?'
            }
        }
    }
    stage ("Upload to store") {
        if (env.BRANCH_NAME.startsWith("release")) {
            node ('master') {
                // Archive artifacts from other jobs/branches
                step ([$class: 'CopyArtifact', projectName: 'quality', filter: '**/*.apk', target: 'quality'])
                step ([$class: 'CopyArtifact', projectName: 'master', filter: '**/*.apk', target: 'master'])
                archiveArtifacts artifacts: '**/*.apk', fingerprint: true
                // ToDo: Release to Play Store
                echo 'Mock: Release to Play Store'
                // Promote to develop
                sh "${gitPromote} -m 'Merge from ${env.BRANCH_NAME} with Jenkins' ${env.BRANCH_NAME} develop"
                // Release TAG and delete release branch
                sh 'git checkout master'
                sh 'git pull --ff-only'
                sh 'git tag ' + tag + ' -m "Release ' + tag + '"'
                sh 'git push --tags'
                sh 'git push origin :' + env.BRANCH_NAME
            }
        }
    }
} catch (e) {
    currentBuild.result = 'FAILED'
    node {
        mail to: to, cc: "your_address@example.com", subject: "Job ${env.JOB_NAME} [${env.BUILD_NUMBER}] finished with ${currentBuild.result}", body: "See ${env.BUILD_URL}/console"
    }
    throw e
}
