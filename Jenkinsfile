@Library('jenkins-shared-library@main') _

pipeline {
    agent{
        label 'AGENT-01'
    }

    stages {
    
        stage('Build Docker Image') {
            agent {
                docker {
                    image '814200988517.dkr.ecr.us-west-2.amazonaws.com/docker-images:base-image'
                    args '-v /var/run/docker.sock:/var/run/docker.sock --privileged '
                    reuseNode true
                }
            }
            environment {
                DOCKER_CONFIG = '/tmp/docker'
            }
            steps {
                dockerBuild(
                    versionTag: "1.0",
                    imageName: "terraform-image"
                )
                trivyScan(
                    imageName: "terraform-image",
                    versionTag: "1.0"
                )
            }
        }
    }
}