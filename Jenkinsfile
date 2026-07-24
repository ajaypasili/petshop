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
                docker rmi -f tomcat-image
                docker build -t tomcat-image .
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
                    credentialsId: 'docker-jenkins',
                    usernameVariable: 'ajaypasili',
                    passwordVariable: 'Ajay@2001'
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
                docker push ajaypasili/tomcat-image
                '''
            }
        }
        stage('Deploy to Minikube') {
           steps {
        sh '''
        kubectl apply -f deployment.yaml
        kubectl apply -f service.yaml
        '''
           }
        }
    
    }
}
