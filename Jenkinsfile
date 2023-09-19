@Library('jenkins-shared-library@develop') _

def awsRegion = "us-west-2"
def imageName = "terraform-image"
def versionTag = "1.0.0"
def emailRecipient = "aswin@crunchops.com"

pipeline {
    agent {
        label 'AGENT-01'
    }

    stages {
        stage('Lint Dockerfile') {
            steps {
                hadoLint()
            }
        }
        stage('Checkov Scan') {
            steps {
                checkovDockerScan([
                    customPolicy: 'CUSTOM_DOCKER_001'
                ])
            }
        }
        stage('ECR Login') {
            steps {
                script {
                    ecrRegistry.ecrLogin(
                        "${ECR_REGISTRY}",
                        "${awsRegion}"
                    )
                }
            }
        }
        stage('Build Docker Image') {
            agent {
                docker {
                    image "${ECR_REGISTRY}/base-image:${versionTag}"
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
                            versionTag: versionTag,
                            imageName: imageName
                        )
                    } catch (Exception buildError) {
                        currentBuild.result = 'FAILURE'
                        error("Failed to build Docker image: ${buildError}")
                    }
                }
            }
        }
        stage('Run Trivy Scan') {
            agent {
                docker {
                    image "${ECR_REGISTRY}/base-image:${versionTag}"
                    args '-v /var/run/docker.sock:/var/run/docker.sock --privileged '
                }
            }
            steps {
                script {
                    try {
                        def imageNameAndTag = "${imageName}:${versionTag}"
                        trivyScan(imageNameAndTag)
                    } catch (Exception trivyError) {
                        currentBuild.result = 'FAILURE'
                        error("Trivy scan failed: ${trivyError}")
                    }
                }
            }
        }
        stage('Send Trivy Report') {
            agent {
                docker {
                    image "${ECR_REGISTRY}/base-image:${versionTag}"
                }
            }
            steps {
                script {
                    try {
                        def imageNameAndTag = "${imageName}:${versionTag}"
                        def reportPath = "${WORKSPACE}/trivy-report.html"
                        def recipient = "${emailRecipient}"
                        emailReport(reportPath, imageNameAndTag, recipient)
                    } catch (Exception emailError) {
                        currentBuild.result = 'FAILURE'
                        error("Email Send failed: ${emailError}")
                    }
                }
            }
        }
        stage('Push Image To ECR') {
            when {
                branch 'main'
            }
            steps {
                script {
                    try {
                        ecrRegistry(
                            ecrRepository: "${ECR_REGISTRY}/docker-images",
                            imageName: "${imageName}",
                            versionTag: "${versionTag}",
                            awsRegion: "${awsRegion}"
                        )
                    } catch (Exception pushError) {
                        currentBuild.result = 'FAILURE'
                        error("Failed to push image to ECR: ${pushError}")
                    }
                }
            }
        }
    }

    post {
        success {
            script {
                emailNotification.sendEmailNotification('success', "${emailRecipient}")
            }
        }
        failure {
            script {
                emailNotification.sendEmailNotification('failure', "${emailRecipient}")
            }
        }
        always {
            cleanWs()
        }
    }
}