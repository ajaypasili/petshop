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
                withSonarQubeEnv('ajay-sonar') {
                    sh 'mvn clean verify org.sonarsource.scanner.maven:sonar-maven-plugin:sonar'
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                docker rmi -f tomcat-image:v2
                docker build -t tomcat-image:v2 .
                '''
            }
        }

        stage('Trivy Scan') {
            steps {
                sh 'trivy image --severity HIGH,CRITICAL --exit-code 0 tomcat-image:v2'
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub',
                    usernameVariable: 'ajaypasili',
                    passwordVariable: 'Ajay@2001'
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
                docker tag tomcat-image:v2 ajaypasili/tomcat-image:v2
                docker push ajaypasili/tomcat-image:v2
                '''
            }
        }

        stage('Update Kubeconfig') {
            steps {
                sh 'aws eks --region ap-south-1 update-kubeconfig --name my-cluster1'
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh '''
                kubectl apply -f deployment.yaml
                kubectl apply -f service.yaml
                kubectl rollout status deployment/petshop
                '''
            }
        }
    }
}
