pipeline {
    agent {
        docker {
            image 'mcr.microsoft.com/dotnet/sdk:8.0'
        }
    }

    environment {
        BUILD_IMAGE_NAME = "blazorcrud-app"
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code from Git...'
                git branch: 'main', credentialsId: 'github-eugene', url: 'https://github.com/admEug/dotnet-blazor-crud.DM.git'
            }
        }

        stage('Restore Dependencies') {
            steps {
                echo 'Restoring .NET dependencies...'
                sh 'dotnet restore'
            }
        }

        stage('Build') {
            steps {
                echo 'Building projects...'
                sh 'dotnet build --no-restore'
            }
        }

        stage('Run Tests') {
            steps {
                echo 'Running unit tests...'
                sh 'dotnet test Blazorcrud.Server.Tests --no-build'
                echo 'Running integration tests...'
                sh 'dotnet test Blazorcrud.Server.IntegrationTests --no-build'
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                echo 'Building Docker image...'
                script {
                    def imageName = "${BUILD_IMAGE_NAME}:${BUILD_NUMBER}"
                    sh "docker build -t ${imageName} ."
                }
            }
        }
        
        stage('Deploy Locally') {
            steps {
                echo 'Deploying and running the Docker container...'
                script {
                    def imageName = "${BUILD_IMAGE_NAME}:${BUILD_NUMBER}"
                    sh 'docker stop blazorcrud-container || true'
                    sh 'docker rm blazorcrud-container || true'
                    sh "docker run -d -p 80:80 --name blazorcrud-container ${imageName}"
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished. Cleaning up workspace...'
            cleanWs()
        }
        success {
            echo 'Build successful!'
        }
        failure {
            echo 'Build failed!'
        }
    }
}