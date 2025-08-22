pipeline {
    agent any

    environment {
        BUILD_IMAGE_NAME = "blazorcrud-app"
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Code has been checked out automatically.'
            }
        }

        stage('Install Docker') {
            steps {
                echo 'Installing Docker client...'
                script {
                    sh 'apt-get update'
                    sh 'apt-get install -y docker-compose' // Added docker-compose
                    sh 'apt-get install -y docker.io'
                    sh 'which docker'
                }
            }
        }
        
        stage('Start Services') {
            steps {
                echo 'Starting Docker Compose services...'
                script {
                    sh 'docker-compose up --build -d'
                    sh 'sleep 2' // Give services time to start
                }
            }
        }
        
        stage('Restore Dependencies') {
            steps {
                echo 'Restoring .NET dependencies...'
                script {
                    docker.image('mcr.microsoft.com/dotnet/sdk:8.0').inside {
                        sh 'dotnet restore'
                    }
                }
            }
        }

        stage('Build') {
            steps {
                echo 'Building projects...'
                script {
                    docker.image('mcr.microsoft.com/dotnet/sdk:8.0').inside {
                        sh 'dotnet build'
                    }
                }
            }
        }

        stage('Run Tests') {
            steps {
                echo 'Running tests...'
                script {
                    docker.image('mcr.microsoft.com/dotnet/sdk:8.0').inside {
                        sh 'dotnet test Blazorcrud.Server.Tests --no-build'
                        sh 'dotnet test Blazorcrud.Server.IntegrationTests --no-build'
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished. Cleaning up workspace...'
            sh 'docker-compose down'
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