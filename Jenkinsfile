pipeline {
    agent any
    environment {
        AWS_REGION = "us-east-2"
        ECR_REPO = "708254703418.dkr.ecr.us-east-2.amazonaws.com/vprofile-app"
    }
    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Uliwazeer/Graduation-Project.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'sudo docker build -t vprofile-app:latest ./tom-app'
            }
        }

        stage('Login to ECR') {
            // استخدم credentials المخزنة في Jenkins
            withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-id']]) {
                steps {
                    sh '''
                        aws ecr get-login-password --region $AWS_REGION | sudo docker login --username AWS --password-stdin $ECR_REPO
                    '''
                }
            }
        }

        stage('Push Image To ECR') {
            steps {
                sh '''
                    sudo docker tag vprofile-app:latest $ECR_REPO:${BUILD_NUMBER}
                    sudo docker push $ECR_REPO:${BUILD_NUMBER}
                '''
            }
        }

        stage('Update GitOps Repo') {
            steps {
                sh '''
                    git clone https://github.com/Uliwazeer/gitops-vprofile.git
                    cd gitops-vprofile
                    sed -i "s|image: .*|image: $ECR_REPO:${BUILD_NUMBER}|g" deployment.yaml
                    git commit -am "update image tag to ${BUILD_NUMBER}"
                    git push
                '''
            }
        }
    }
}
