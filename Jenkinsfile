@Library('jenkins-shared-library@develop') _

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
        stage('Send Trivy Report') {
            steps {
                script {
                    try {
                        def imageNameAndTag = "terraform-image:1.0"
                        def reportPath = "/home/ubuntu/*.html"
                        def recipient = "aswin@crunchops.com"
                        emailReport(reportPath,imageNameAndTag, recipient)
                    } catch (Exception emailError) {
                        currentBuild.result = 'FAILURE'
                        error("Email Send failed: ${emailError}")
                    }
                }
                }
            }
        stage('Slim Docker Image') {
            when {
                expression { false }
            }
            steps {
                script {
                    try {
                        def imageNameAndTag = "terraform-image:1.0"
                        slimImage(imageNameAndTag)
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        error("Failed to slim Docker image: ${e.message}")
                    }
                }
            }
        }
    }

    post {
        success {
            emailext(
                subject: "Terraform Pipeline Success",
                body: "The Terraform pipeline has successfully completed.",
                recipientProviders: [[$class: 'CulpritsRecipientProvider']],
                to: 'aswin@crunchops.com',
                attachLog: true,
            )
        }
        failure {
            emailext(
                subject: "Terraform Pipeline Failed",
                body: "The Terraform pipeline has failed. Please investigate.",
                recipientProviders: [[$class: 'CulpritsRecipientProvider']],
                to: 'aswin@crunchops.com',
                attachLog: true,
            )
        }
    always {
        cleanWs()
        }
    }
}

