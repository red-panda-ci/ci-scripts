#!groovy

// Configurables
def sdkVersion = "23.0.3"
def gitPromote = "wget -O - https://raw.githubusercontent.com/pedroamador/git-promote/master/git-promote | bash -s -- "
def to = emailextrecipients([[$class: 'DevelopersRecipientProvider'],[$class: 'CulpritsRecipientProvider'],[$class: 'UpstreamComitterRecipientProvider'],[$class: 'FirstFailingBuildSuspectsRecipientProvider'],[$class: 'FailingTestSuspectsRecipientProvider']])
def lane = (env.BRANCH_NAME in ['develop','staging','quality','master'] ? env.BRANCH_NAME : 'develop')

pipeline {
    agent none

    stages {
        stage ('Build') {
            agent { label 'docker' }
            when { expression { (env.BRANCH_NAME in ['develop','staging','quality','master'] || env.BRANCH_NAME.startsWith('PR-')) ? true : false } }
            steps  {
                wrap ([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'XTerm']) {
                    checkout scm
                    sh 'git submodule update --init'
                    sh 'ci-scripts/common/bin/buildApk.sh --sdkVersion=' + sdkVersion + ' --lane="' + lane + '"'
                }
            }
        }
        stage ('Archive artifacts') {
            agent { label 'docker' }
            when { expression { env.BRANCH_NAME in ['develop','staging','quality','master'] ? true : false } }
            steps {
                archive '**/*.apk'
            }
        }
        stage('Sonarqube Analysis') {
            agent { label 'docker' }
            when { expression { ((env.BRANCH_NAME == 'develop') || env.BRANCH_NAME.startsWith('PR-')) ? true : false } }
            steps {
                wrap ([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'XTerm']) {
                    script {
                        def sonarHome = tool 'SonarQube'
                        timeout(time: 1, unit: 'HOURS') {
                            withSonarQubeEnv('SonarQube') {
                                sh "${sonarHome}/bin/sonar-scanner"
                            }
                            def qg = waitForQualityGate()
                            if (qg.status != 'OK') {
                                error "Pipeline aborted due to quality gate failure: ${qg.status}"
                            }
                        }
                    }
                }
            }
        }
        stage ('Promote to quality') {
            agent { label 'master' }
            when { branch 'release/*' }
            steps {
                script {
                    item = env.BRANCH_NAME.split("/")
                    tag = item[1]
                }
                checkout scm
                sh 'git submodule update --init'
                sh "${gitPromote} -m 'Merge from ${env.BRANCH_NAME} with Jenkins' ${env.BRANCH_NAME} quality"
                build (job: 'quality', wait: true)
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
                sh "${gitPromote} -m 'Merge from quality with Jenkins' quality master"
                build (job: 'master', wait: true)
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
                // Archive artifacts from other jobs/branches
                step ([$class: 'CopyArtifact', projectName: 'quality', filter: '**/*.apk', target: 'quality'])
                step ([$class: 'CopyArtifact', projectName: 'master', filter: '**/*.apk', target: 'master'])
                archive '**/*.apk'
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
        stage ('Clean') {
            when { expression { env.BRANCH_NAME.startsWith('PR-') ? true : false } }
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
            hipchatSend color: 'GREEN', failOnError: true, room: 'Integrations,Project', message: "Build #${env.BUILD_NUMBER} finished OK (branch ${env.BRANCH_NAME})", notify: true, server: 'api.hipchat.com', v2enabled: true
            slackSend channel: '#integrations', color: 'good', message: "Build #${env.BUILD_NUMBER} finished OK (branch ${env.BRANCH_NAME})"
        }
        failure {
            hipchatSend color: 'RED', failOnError: true, room: 'Integrations,Project', message: "K.O. in the Build #${env.BUILD_NUMBER} (branch ${env.BRANCH_NAME})", notify: true, server: 'api.hipchat.com', v2enabled: true
            slackSend channel: '#integrations', color: 'danger', message: "K.O. in the Build #${env.BUILD_NUMBER} (branch ${env.BRANCH_NAME})"
            mail to: to, cc: "your_address@example.com", subject: "Job ${env.JOB_NAME} [${env.BUILD_NUMBER}] finished with ${currentBuild.result}", body: "See ${env.BUILD_URL}/console"
        }
    }

    options {
        skipDefaultCheckout()
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }
}
