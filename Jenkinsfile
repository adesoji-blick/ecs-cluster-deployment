pipeline {
    agent any
        environment {
            AWS_ACCESS_KEY_ID     = credentials ('AWS_ACCESS_KEY_ID')
            AWS_SECRET_ACCESS_KEY = credentials ('AWS_SECRET_ACCESS_KEY')
            AWS_DEFAULT_REGION    = credentials ('AWS_DEFAULT_REGION')
            ECR_REPO = '861694884470.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/direction-app'
            BUILD_NUMBER = '11'
        } 
    stages {
        stage('Build & Tag Docker Image for Directions App') {
            steps {
                // Building Docker Image for Directions App
                sh "sudo docker build -t direction-app:latest ."   
                // Tag Docker Image for Directions App
                sh "echo tagging Docker image for direction-app"
                // sh "sudo docker tag direction-app:latest 861694884470.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/direction-app:2022.0.${BUILD_NUMBER}"
                sh "sudo docker tag direction-app:latest ${ECR_REPO}:2022.3.${BUILD_NUMBER}"     
            }
        }
        stage('Push directions App Docker Image to ECR') {
            steps {
                // Retrieve authentication token and authenticate Docker client to ECR.
                sh "echo Retrieve authentication token and authenticate Docker client to ECR."
                sh "/usr/local/bin/aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | sudo docker login --username AWS --password-stdin ${ECR_REPO}"
                // Push Directions App Docker Image to ECR
                sh "echo Pushing direction-app Docker Image to ECR"
                sh "sudo docker push ${ECR_REPO}:2022.3.${BUILD_NUMBER}"
                }   
           }
        stage('Deploy Image to ECS cluster') {
            // when {
            //     branch "develop"
            // }
            steps {
                // make the update file executable
                sh 'chmod +x ./update.sh'
                // run the update script
                sh './update.sh'
           }
        }
   }
}
