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
        stage('Slim Docker Image') {
            steps {
                script {
                    try {
                        def imageNameAndTag = "terraform-image:1.0"
                        def userPrompt = 'USER INPUT REQUIRED, PRESS <ENTER> WHEN YOU ARE DONE USING THE CONTAINER'
                        slimImage(imageNameAndTag, userPrompt)
                    } catch (Exception slimError) {
                        currentBuild.result = 'FAILURE'
                        error("Slimming Docker image failed: ${slimError}")
                    }
                }
            }
        }
    }

    post {
        failure {
        emailext subject: "Build Failure: ${currentBuild.fullDisplayName}",
                body: "The build ${currentBuild.fullDisplayName} failed. Please investigate and take necessary actions.",
                to: 'aswin@crunchops.com',
                replyTo: 'aswin@crunchops.com',
                mimeType: 'text/html'
    }
    success {
        emailext subject: "Build Success: ${currentBuild.fullDisplayName}",
                body: "The build ${currentBuild.fullDisplayName} succeeded. Good job!",
                to: 'aswin@crunchops.com',
                replyTo: 'aswin@crunchops.com',
                mimeType: 'text/html'
        always {
            cleanWs()
        }
    }
}

