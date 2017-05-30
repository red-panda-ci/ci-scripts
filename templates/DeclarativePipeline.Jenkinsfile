#!groovy

@Library('github.com/pedroamador/jenkins-pipeline-library') _

// Configurables
def sdkVersion = '23.0.3'
def lane = (env.BRANCH_NAME in ['develop','staging','quality','master'] ? env.BRANCH_NAME : 'develop')

pipeline {
    agent none

    stages {
        stage ('Build') {
            agent { label 'docker' }
            when { expression { (env.BRANCH_NAME in ['develop','staging','quality','master']) || env.BRANCH_NAME.startsWith('PR-') } }
            steps  {
                timestamps {
                    ansiColor('xterm') {
                        checkout scm
                        sh 'git submodule update --init && ci-scripts/common/bin/buildApk.sh --sdkVersion=' + sdkVersion + ' --lane=' + lane
                    }
                }
            }
        }
        stage ('Archive artifacts') {
            agent { label 'docker' }
            when { expression { env.BRANCH_NAME in ['develop','staging','quality','master'] } }
            steps {
                archive '**/*.apk'
            }
        }
        stage('Sonarqube Analysis') {
            agent { label 'docker' }
            when { expression { (env.BRANCH_NAME == 'develop') || env.BRANCH_NAME.startsWith('PR-') } }
            steps {
                jplSonarScanner ('SonarQube')
            }
        }
        stage ('Promote to Quality') {
            agent { label 'master' }
            when { branch 'release/*' }
            steps {
                jplPromote (env.BRANCH_NAME,'quality')
            }
        }
        stage ('Confirm UAT') {
            agent none
            when { branch 'release/*' }
            steps {
                timeout(time: 5, unit: 'DAYS') {
                    input(message: 'Waiting for UAT. Build release?')
                }
            }
        }
        stage ('Promote to master') {
            agent { label 'master' }
            when { branch 'release/*' }
            steps {
                jplPromote ('quality','master')
            }
        }
        stage ('Confirm Release') {
            agent none
            when { branch 'release/*' }
            steps {
                timeout(time: 5, unit: 'DAYS') {
                    input(message: 'Waiting for approval - Upload to Play Store?')
                }
            }
        }
        stage ('Upload to store') {
            agent { label 'master' }
            when { branch 'release/*' }
            steps {
                timestamps {
                    ansiColor('xterm') {
                        // Archive artifacts from other jobs/branches
                        step ([$class: 'CopyArtifact', projectName: 'staging', filter: '**/*.apk', target: 'staging'])
                        step ([$class: 'CopyArtifact', projectName: 'quality', filter: '**/*.apk', target: 'quality'])
                        step ([$class: 'CopyArtifact', projectName: 'master', filter: '**/*.apk', target: 'master'])
                        archive '**/*.apk'
                        // ToDo: Release to Play Store
                        jplCloseRelease()
                        jplNotify('The-Project','#the-project','the-project@example.com')
                    }
                }
            }
        }
        stage ('Clean') {
            when { expression { env.BRANCH_NAME.startsWith('PR-') } }
            agent { label 'docker' }
            steps {
                deleteDir();
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished'
        }
        success {
            echo 'Build OK'
        }
        failure {
            echo 'Build failed!'
            jplNotify('The-Project','#the-project','the-project@example.com')
        }
    }

    options {
        skipDefaultCheckout()
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }
}
