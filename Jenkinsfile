pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = "AKIARENAYJ3PI4CTWPOQ"
        AWS_SECRET_ACCESS_KEY = "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"
        AWS_DEFAULT_REGION = "ap-south-2"
    }

    stages {
        stage('Clone Repo') {
            steps {
                git branch: 'main', url: 'https://github.com/JathinKodali/finops-pipeline.git'
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve -var="email=kodalijathin@gmail.com"'
            }
        }
    }
}
