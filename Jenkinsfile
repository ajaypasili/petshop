pipeline {
    agent any

    stages {

        stage('Git Checkout') {
            steps {
                git branch: 'master',
                url: 'https://github.com/ajaypasili/petshop.git'
            }
        }

        stage('SonarQube Scan') {
            steps {
                withSonarQubeEnv('jenkins-sonar') {
                    sh 'mvn verify sonar:sonar'
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                docker rmi -f petshop:v1
                docker build -t petshop:v1 .
                '''
            }
        }

        stage('Trivy Scan') {
            steps {
                sh 'trivy image --severity HIGH,CRITICAL --exit-code 0 petshop:v1'
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'jenkins-docker',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    '''
                }
            }
        }

        stage('Docker Push') {
            steps {
                sh '''
                docker tag petshop:v1 ajaypasili/petshop:v1
                docker push ajaypasili/petshop:v1
                '''
            }
        }

        stage('Update Kubeconfig') {
            steps {
                sh 'aws eks --region ap-south-1 update-kubeconfig --name my-cluster'
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh '''
                kubectl apply -f deployment.yaml
                kubectl apply -f service.yaml
                '''
            }
        }
    }
}
