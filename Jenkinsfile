pipeline {
    agent any
        environment {
            AWS_ACCESS_KEY_ID     = credentials ('AWS_ACCESS_KEY_ID')
            AWS_SECRET_ACCESS_KEY = credentials ('AWS_SECRET_ACCESS_KEY')
            AWS_DEFAULT_REGION    = credentials ('AWS_DEFAULT_REGION')
            BUILD_NUMBER = '203'
        } 
    stages {
        stage('Build & Tag Docker Image for Directions App') {
            steps {
                // Building Docker Image for Directions App
                sh "sudo docker build -t direction-app:latest ."   
                // Tag Docker Image for Directions App
                sh "echo tagging Docker image for direction-app"
                sh "sudo docker tag direction-app:latest 319670758662.dkr.ecr.ca-central-1.amazonaws.com/direction-app:0.0.${BUILD_NUMBER}"     
            }
        }
        stage('Push directions App Docker Image to ECR') {
            steps {
                // Retrieve authentication token and authenticate Docker client to ECR.
                sh "echo Retrieve authentication token and authenticate Docker client to ECR."
                sh "/usr/local/bin/aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | sudo docker login --username AWS --password-stdin 319670758662.dkr.ecr.ca-central-1.amazonaws.com/direction-app"
                // Push Directions App Docker Image to ECR
                sh "echo Pushing direction-app Docker Image to ECR"
                sh "sudo docker push 319670758662.dkr.ecr.ca-central-1.amazonaws.com/direction-app:0.0.${BUILD_NUMBER}"
                }   
           }
        stage('Deploy Image to ECS cluster') {
            // when {
            //     branch "develop"
            // }
            steps {
                // make the update file executable
                sh 'chmod +x ./updated.sh'
                // run the update script
                sh './updated.sh'
           }
        }
   }
}
