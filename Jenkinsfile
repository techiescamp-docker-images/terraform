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
                        // Handle any exceptions if needed
                        currentBuild.result = 'FAILURE'
                        error("Failed to slim Docker image: ${e.message}")
                    }
                }
            }
        }
    }

    post {
        success {
            emailext subject: "Build Successful: \${currentBuild.fullDisplayName}",
                    body: "The build was successful. Click [here](\${BUILD_URL}) to see the details.",
                    to: 'aswin@crunchops.com'
        }
        failure {
            emailext subject: "Build Failed: \${currentBuild.fullDisplayName}",
                    body: "The build failed. Click [here](\${BUILD_URL}) to see the details.",
                    to: 'aswin@crunchops.com'
        }
    always {
        cleanWs()
        }
    }
}

