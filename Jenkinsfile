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
                withSonarQubeEnv('mysonarqube') {
                sh 'mvn verify sonar:sonar'
                }
            }
        }

        stage('docker build'){
            steps {
                sh '''
                docker rmi -f tomcat-image
                docker build -t tomcat-image .
                docker run -dit --name mycont1 -p 8085:8080 tomcat-image
                '''
            }
        }
    }
}
