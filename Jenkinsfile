
pipeline {
    agent{
        label 'AGENT-01'
    }
    stages{
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build'){
            steps{
                sh '''
                docker build -t terraform-image:01 .
                '''
                }
            }
        stage('Scan Image') {
            steps {
            sh '''
            sudo trivy image terraform-image:01
            '''
            }
        }
    }
}