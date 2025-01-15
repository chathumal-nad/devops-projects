pipeline {
    agent any

    stages {
        stage('Check Versions') {
            steps {
                sh 'sudo apt update -y'
                // sh 'sudo apt upgrade -y'
                sh 'python3 --version'
                sh 'docker -v'
            }
        }
        
        stage('install make') {
            steps {
                sh 'sudo apt install make -y'
            }
        }

        stage('Checkout') {
            steps {
                git changelog: false, poll: false, url: 'https://github.com/chathumal-nad/python-flask-demoapp.git'
            }
        }
        
        stage('Docker build') {
            steps {
                sh 'make image'
            }
        }        
        
        stage('Docker push') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-credentials') {
                        sh "make push"
                    }
                }
            }
        }
        
        stage('Deploy App') {
            steps {
                sh 'make deploy'
            }
        }         
    }
}

