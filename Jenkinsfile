pipeline {
    agent any 
    stages {
        stage('git checkout') {
            steps {
                git branch: 'master' ,
                url: 'https://github.com/ajaypasili/petshop.git'

            }
        }

        stage('sonar scanner') {
            steps {
                withSonarQubeEnv('ajay-sonar') {
                sh 'mvn verify sonar:sonar'
                }
            }
        }

        stage('docker build'){
            steps {
                sh '''
                docker rmi -f tomcat-image:v2
                docker build -t tomcat-image:v2 .
                '''
            }
        }
        stage('trivy image scan'){
            steps {
                sh ' trivy image --severity HIGH,CRITICAL --exit-code 0 tomcat-image'
            }
        }
        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker -jenkins',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    '''
                }
            }
        }
        stage('docker push'){
            steps {
                sh '''
                docker tag tomcat-image:v2 ajaypasili/tomcat-image:v2
                docker push ajaypasili/tomcat-image:v2
                '''
            }
        }
        stage('eks update') {
           steps {
        sh 'aws eks --region ap-south-1 update-kubeconfig --name my-cluster1'
           }
        }

        stage('eks deployment') {
            steps {
                sh '''
                kubectl apply -f deployment.yaml
                kubectl apply -f service.yaml
                '''
            }
        }
    
    }
}
