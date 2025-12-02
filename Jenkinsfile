pipeline {
    agent any
    environment {
        AWS_REGION = "us-east-2"
        ECR_REPO = "708254703418.dkr.ecr.us-east-2.amazonaws.com/vprofile-app"
    }
    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Uliwazeer/Graduation-Project.git', credentialsId: 'github-token'
            }
        }

        stage('Clean Old Docker Images & Containers') {
            steps {
                sh '''
                    echo "Removing old Docker images and containers..."
                    sudo docker container prune -f
                    sudo docker image prune -af
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'sudo docker build -t vprofile-app:latest ./tom-app'
            }
        }

        stage('Login to AWS ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-key']]) {
                    sh '''
                        echo "Logging into AWS ECR..."
                        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                        export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                        aws ecr get-login-password --region $AWS_REGION | sudo docker login --username AWS --password-stdin $ECR_REPO
                    '''
                }
            }
        }

        stage('Push Image To ECR') {
            steps {
                sh '''
                    echo "Tagging and pushing Docker image to ECR..."
                    sudo docker tag vprofile-app:latest $ECR_REPO:${BUILD_NUMBER}
                    sudo docker push $ECR_REPO:${BUILD_NUMBER}
                '''
            }
        }

        stage('Update GitOps Repo') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'github-token', passwordVariable: 'GITHUB_PASS', usernameVariable: 'GITHUB_USER')]) {
                    sh '''
                        echo "Updating GitOps repository..."
                        git clone https://$GITHUB_USER:$GITHUB_PASS@github.com/Uliwazeer/gitops-vprofile.git
                        cd gitops-vprofile
                        sed -i "s|image: .*|image: $ECR_REPO:${BUILD_NUMBER}|g" deployment.yaml
                        git commit -am "Update image tag to ${BUILD_NUMBER}"
                        git push
                    '''
                }
            }
        }
    }
}
