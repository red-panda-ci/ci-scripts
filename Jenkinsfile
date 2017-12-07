#!groovy

@Library('github.com/red-panda-ci/jenkins-pipeline-library') _

// Initialize global config
cfg = jplConfig('ci-scripts', 'library', '', [hipchat: '', slack: '#integrations', email:'redpandaci+ci-scripts@gmail.com'])

pipeline {
    agent none

    stages {
        stage ('Initialize') {
            agent { label 'docker' }
            steps  {
                jplStart(cfg)
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
