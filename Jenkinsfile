#!groovy

@Library('github.com/red-panda-ci/jenkins-pipeline-library@v2.6.2') _

// Initialize global config
cfg = jplConfig('ci-scripts','lib','', [hipchat: '', slack: '#integrations', email:'redpandaci+ci-scripts@gmail.com'])

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
            when { expression { (env.BRANCH_NAME == 'develop') || env.BRANCH_NAME.startsWith('PR-') || env.BRANCH_NAME.startsWith('release/v') } }
            steps  {
                sh 'bin/test.sh'
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
            when { expression { env.BRANCH_NAME.startsWith('release/v') && cfg.promoteBuild.enabled } }
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
