pipeline {
    agent any
        environment {
            AWS_ACCESS_KEY_ID     = credentials ('AWS_ACCESS_KEY_ID')
            AWS_SECRET_ACCESS_KEY = credentials ('AWS_SECRET_ACCESS_KEY')
            AWS_DEFAULT_REGION    = credentials ('AWS_DEFAULT_REGION')
            BUILD_NUMBER = '1'
        } 
    stages {
        stage('Build & Tag Docker Image for SolarBase-backend') {
            steps {
                // Building Docker Image for SolarBase Backend
                sh "sudo docker build -t solarbase-backend:latest ."   
                // Tag Docker Image for Solarbase Backend
                sh "sudo docker tag solarbase-backend:latest 319670758662.dkr.ecr.ca-central-1.amazonaws.com/solarbase-backend:0.0.${BUILD_NUMBER}"     
            }
        }
        stage('Push SolarBase Docker Image to ECR') {
            steps {
                // Retrieve authentication token and authenticate Docker client to ECR.
                sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | sudo docker login --username AWS --password-stdin 319670758662.dkr.ecr.ca-central-1.amazonaws.com"
                // Push SolarBase Backend Docker Image to ECR
                sh "docker push 319670758662.dkr.ecr.ca-central-1.amazonaws.com/solarbase-backend:0.0.${BUILD_NUMBER}"
                }   
           }
        }

        // stage('Manage Develop Branch for Test App') {
        //     when {
        //         branch "develop"
        //     }
        //     steps {
        //         // tag docker image for dev app and push to docker.io
        //         sh "sudo docker tag direction-app:latest blickng/direction-app-dev:latest"
        //         withCredentials([string(credentialsId: 'DockerUserID', variable: 'dockerusername'), string(credentialsId: 'DockerPassword', variable: 'dockerpassword')]) {
        //         sh "sudo docker login -u blickng -p $dockerpassword"
        //         sh "sudo docker push blickng/direction-app-dev:latest"
        //         sh "sudo docker logout"
        //         }   
        //         // ssh into dev machine Pull docker image and run container instance in remote machine
        //         withCredentials([sshUserPrivateKey(credentialsId: 'jenkins-key', keyFileVariable: '')]) {
        //         // sh "ssh ec2-user@52.60.57.220 sudo docker rm -f direction-app-dev"     
        //         sh "ssh -o StrictHostKeyChecking=no ec2-user@52.60.57.220 sudo docker run -d -p 8080:8080 -e loginname=myname -e loginpass=mypass -e api_key=xxxxxxxx --name direction-app-dev blickng/direction-app-dev:latest"
        //      }
        //    }
        // }
   }

