pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker-hub-creds') // Jenkins credential ID (username/password type)
        IMAGE_NAME            = "<your-dockerhub-username>/bank-app"
        KUBECONFIG            = "/var/lib/jenkins/.kube/k3s-config" // copied onto Jenkins server, see README
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/<your-username>/<bank-app-repo>.git'
            }
        }

        stage('Build with Maven') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar') { // 'sonar' = name configured in Manage Jenkins -> System
                    sh 'mvn sonar:sonar'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $IMAGE_NAME:$BUILD_NUMBER .'
            }
        }

        stage('Push to DockerHub') {
            steps {
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                sh 'docker push $IMAGE_NAME:$BUILD_NUMBER'
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl set image deployment/bank-app bank-app=$IMAGE_NAME:$BUILD_NUMBER'
                sh 'kubectl rollout status deployment/bank-app'
            }
        }
    }

    post {
        success {
            echo 'Deployed to k3s — metrics should already be flowing into Prometheus/Grafana.'
        }
        failure {
            echo 'Pipeline failed — check the stage logs above.'
        }
    }
}
