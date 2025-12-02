pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-2'
        ECR_REPO = '708254703418.dkr.ecr.us-east-2.amazonaws.com/app-vprofile'
        IMAGE_NAME = 'vprofile-app'
    }

    stages {
        stage('Checkout Code') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'github-token', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_PASS')]) {
                    sh '''
                        [ -d Graduation-Project ] && rm -rf Graduation-Project
                        git clone https://${GIT_USER}:${GIT_PASS}@github.com/Uliwazeer/Graduation-Project.git
                        cd Graduation-Project
                        git checkout main
                    '''
                }
            }
        }

        stage('Clean Old Docker Images') {
            steps {
                script {
                    def oldImage = sh(script: "sudo docker images ${IMAGE_NAME} -q", returnStdout: true).trim()
                    if (oldImage) {
                        sh "sudo docker rmi -f ${oldImage}"
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "sudo docker build -t ${IMAGE_NAME}:latest ./tom-app"
            }
        }

        stage('Login to AWS ECR') {
            steps {
                withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
                    sh "aws ecr get-login-password --region ${AWS_REGION} | sudo docker login --username AWS --password-stdin ${ECR_REPO}"
                }
            }
        }

        stage('Push Image To ECR') {
            steps {
                sh """
                    sudo docker tag ${IMAGE_NAME}:latest ${ECR_REPO}:latest
                    sudo docker push ${ECR_REPO}:latest
                """
            }
        }

        stage('Update GitOps Repo') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'github-token', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_PASS')]) {
                    sh '''
                        cd Graduation-Project
                        git config user.email "jenkins@example.com"
                        git config user.name "Jenkins"
                        git add .
                        git commit -m "Update deployment image to latest" || echo "No changes to commit"
                        git push https://${GIT_USER}:${GIT_PASS}@github.com/Uliwazeer/Graduation-Project.git main
                    '''
                }
            }
        }
    }
}
