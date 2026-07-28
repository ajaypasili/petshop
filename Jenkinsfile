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
                docker rmi -f tomcat1-image:v2
                docker build -t tomcat1-image:v2 .
                '''
            }
        }

        stage('Trivy Scan') {
            steps {
                sh 'trivy image --severity HIGH,CRITICAL --exit-code 0 tomcat1-image:v2'
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-jenkins',
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
                docker tag tomcat1-image:v2 ajaypasili/tomcat1-image:v2
                docker push ajaypasili/tomcat1-image:v2
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
                '''
            }
        }
    }
}
