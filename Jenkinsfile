@Library('jenkins-shared-library@develop') _

pipeline {
    agent {
        label 'AGENT-01'
    }

    stages {
        stage('Lint Dockerfile') {
            steps {
                hadolint()
            }
        }
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
                script {
                    try {
                        dockerBuild(
                            versionTag: "1.0",
                            imageName: "terraform-image"
                        )
                    } catch (Exception buildError) {
                        currentBuild.result = 'FAILURE'
                        error("Failed to build Docker image: ${buildError}")
                    }
                }
            }
        }
        
        stage('Run Trivy Scan') {
            steps {
                script {
                    try {
                        def imageNameAndTag = "terraform-image:1.0"
                        trivyScan(imageNameAndTag)
                    } catch (Exception trivyError) {
                        currentBuild.result = 'FAILURE'
                        error("Trivy scan failed: ${trivyError}")
                    }
                }
            }
        }
        stage('Run Slim Build') {
            steps {
                script {
                    try {
                        def slimImageInfo = [imageName: 'terraform-image', tag: '1.0']
                        slimBuild(slimImageInfo)
                    } catch (Exception error) {
                        currentBuild.result = 'FAILURE'
                        error("An error occurred: ${error}")
                    }
                }
            }
    }
    }

    post {
        always {
            cleanWs()
        }
    }
}

