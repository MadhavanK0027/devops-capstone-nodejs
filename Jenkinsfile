pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'maddy0027/devops-node-app'
        APP_SERVER = 'ubuntu@44.197.131.111'
        SSH_KEY = '/var/lib/jenkins/.ssh/Capstone_EMC.pem'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                    cd app
                    npm install
                '''
            }
        }

        stage('Test') {
            steps {
                sh '''
                    cd app
                    npm test
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .
                '''
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh '''
                        echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
                        docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                    '''
                }
            }
        }

        stage('Deploy to App Server') {
            steps {
                sh '''
                    ssh -i ${SSH_KEY} \
                        -o StrictHostKeyChecking=no \
                        ${APP_SERVER} "
                            docker pull ${DOCKER_IMAGE}:${BUILD_NUMBER} &&
                            docker stop devops-node-app || true &&
                            docker rm devops-node-app || true &&
                            docker run -d \
                                --name devops-node-app \
                                -p 3000:3000 \
                                --restart unless-stopped \
                                ${DOCKER_IMAGE}:${BUILD_NUMBER}
                        "
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                    ssh -i ${SSH_KEY} \
                        -o StrictHostKeyChecking=no \
                        ${APP_SERVER} \
                        "docker ps --filter name=devops-node-app"
                '''
            }
        }
    }

    post {
        success {
            echo 'CI/CD Pipeline completed successfully!'
        }

        failure {
            echo 'Pipeline failed!'
        }
    }
}