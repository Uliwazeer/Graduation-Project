pipeline {
    agent any
    environment {
        AWS_REGION = "us-east-2"
        ECR_REPO = "708254703418.dkr.ecr.us-east-2.amazonaws.com/vprofile-app"
        IMAGE_NAME = "vprofile-app"
    }
    stages {

        stage('Checkout Code') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'github-token', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_PASS')]) {
                    sh """
                    git clone https://$GIT_USER:$GIT_PASS@github.com/Uliwazeer/Graduation-Project.git
                    cd Graduation-Project
                    git checkout main
                    """
                }
            }
        }

        stage('Clean Old Docker Images') {
            steps {
                sh """
                # حذف الصور القديمة لنفس الاسم
                if sudo docker images $IMAGE_NAME -q; then
                    sudo docker rmi -f \$(sudo docker images $IMAGE_NAME -q)
                fi
                """
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "sudo docker build -t $IMAGE_NAME:latest ./tom-app"
            }
        }

        stage('Login to AWS ECR') {
            withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                sh """
                aws ecr get-login-password --region $AWS_REGION | sudo docker login --username AWS --password-stdin $ECR_REPO
                """
            }
        }

        stage('Push Image To ECR') {
            steps {
                sh """
                sudo docker tag $IMAGE_NAME:latest $ECR_REPO:\$BUILD_NUMBER
                sudo docker push $ECR_REPO:\$BUILD_NUMBER
                """
            }
        }

        stage('Update GitOps Repo') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'github-token', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_PASS')]) {
                    sh """
                    git clone https://$GIT_USER:$GIT_PASS@github.com/Uliwazeer/gitops-vprofile.git
                    cd gitops-vprofile
                    sed -i "s|image: .*|image: $ECR_REPO:\$BUILD_NUMBER|g" deployment.yaml
                    git commit -am "update image tag to \$BUILD_NUMBER"
                    git push
                    """
                }
            }
        }
    }
}
