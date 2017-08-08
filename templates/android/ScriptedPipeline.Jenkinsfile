#!groovy

@Library('github.com/pedroamador/jenkins-pipeline-library') _

// Configurables
def sdkVersion = '23.0.3'
def lane = (env.BRANCH_NAME in ['develop','quality','master'] ? env.BRANCH_NAME : 'develop')

try {
    // Only pull in known branches
    stage('Build') {
        if ((env.BRANCH_NAME in ['develop','staging','quality','master']) || env.BRANCH_NAME.startsWith('PR-')) {
            node('docker') {
                timestamps {
                    ansiColor('xterm') {
                        checkout scm
                        sh 'git submodule update --init && ci-scripts/common/bin/buildApk.sh --sdkVersion=' + sdkVersion + ' --lane=' + lane
                    }
                }
            }
        }
    }
    stage ('Archive artifacts') {
        if (env.BRANCH_NAME in ['develop','staging','quality','master']) {
            node('docker') {
                archive '**/*.apk'
            }
        }
    }
    stage('Sonarqube Analysis') {
        if ((env.BRANCH_NAME == 'develop') || env.BRANCH_NAME.startsWith('PR-')) {
            node('docker') {
                jplSonarScanner ('SonarQube')
            }
        }
    }
    stage ('Promote to quality') {
        if (env.BRANCH_NAME.startsWith('release')) {
            node('docker') {
                jplPromote (env.BRANCH_NAME,'quality')
            }
        }
    }
    stage ('Confirm UAT') {
        if (env.BRANCH_NAME.startsWith('release')) {
            timeout(time:5, unit:'DAYS') {
                input message: 'Waiting for UAT - Build release?'
            }
        }
    }
    stage ('Promote to master') {
        if (env.BRANCH_NAME.startsWith('release')) {
            node ('master') {
                jplPromote ('quality','master')
            }
        }
    }
    stage ('Confirm Release') {
        if (env.BRANCH_NAME.startsWith('release')) {
            timeout(time:5, unit:'DAYS') {
                input message: 'Waiting for approval - Upload to Play Store?'
            }
        }
    }
    stage ('Upload to store') {
        if (env.BRANCH_NAME.startsWith('release')) {
            node ('master') {
                timestamps {
                    ansiColor('xterm') {
                        // Archive artifacts from other jobs/branches
                        step ([$class: 'CopyArtifact', projectName: 'staging', filter: '**/*.apk', target: 'staging'])
                        step ([$class: 'CopyArtifact', projectName: 'quality', filter: '**/*.apk', target: 'quality'])
                        step ([$class: 'CopyArtifact', projectName: 'master', filter: '**/*.apk', target: 'master'])
                        archiveArtifacts artifacts: '**/*.apk', fingerprint: true
                        // ToDo: Release to Play Store
                        jplCloseRelease()
                        jplNotify('The-Project','#the-project','the-project@example.com')
                    }
                }
            }
        }
    }
} catch (e) {
    currentBuild.result = 'FAILED'
    node {
        jplNotify('The-Project','#the-project','the-project@example.com')
    }
    throw e
}
