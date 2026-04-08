pipeline {
    agent any

    stages {
        stage('Deploy') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'aws-creds',
                    usernameVariable: 'AWS_ACCESS_KEY_ID',
                    passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                )]) {
                    sh '''
                    export AWS_DEFAULT_REGION=ap-south-2
                    terraform init
                    terraform apply -auto-approve -var="email=kodalijathin@gmail.com"
                    '''
                }
            }
        }
    }
}
