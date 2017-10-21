#!groovy

@Library('github.com/red-panda-ci/jenkins-pipeline-library') _

// Initialize global config
cfg = jplConfig('ci-scripts', 'library', '', [hipchat: '', slack: '#integrations', email:'redpandaci+ci-scripts@gmail.com'])

pipeline {
    agent none

    stages {
        stage ('Build') {
            agent { label 'docker' }
            steps  {
                jplCheckoutSCM(cfg)
            }
        }
        stage ('Test') {
            agent { label 'docker' }
            steps  {
                echo "Volkswagen test type (todo)"
            }
        }
        stage('Sonarqube Analysis') {
            agent { label 'docker' }
            steps {
                jplSonarScanner(cfg)
            }
        }
        stage('Docker push') {
            agent { label 'docker' }
            steps {
                jplDocker(cfg,'redpandaci/android-base', '', 'redpandaci-docker-credentials', 'docker/android-base')
            }
        }
        stage ('Release confirm') {
            when { branch 'release/v*' }
            steps {
                jplPromoteBuild(cfg)
            }
        }
        stage ('Release finish') {
            agent { label 'docker' }
            when { branch 'release/v*' }
            steps {
                jplCloseRelease(cfg)
            }
        }
        stage ('PR Clean') {
            agent { label 'docker' }
            when { branch 'PR-*' }
            steps {
                deleteDir()
            }
        }
    }

    post {
        always {
            jplPostBuild(cfg)
        }
    }

    options {
        timestamps()
        ansiColor('xterm')
        buildDiscarder(logRotator(artifactNumToKeepStr: '20',artifactDaysToKeepStr: '30'))
        disableConcurrentBuilds()
        skipDefaultCheckout()
        timeout(time: 1, unit: 'DAYS')
    }
}
