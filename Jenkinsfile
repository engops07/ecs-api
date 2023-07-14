pipeline {
    agent any
    
    environment {
        REPOSITORY_URI = 'public.ecr.aws/s8h8u3c8/api'
        PROJECT_NAME = "api"
        TASK_NAME = "sample"
        GIT_HASH = "${GIT_COMMIT[0..6]}"
    }

    stages {
        stage('Checkout') {
            steps {
                // 소스 코드 체크아웃
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                // Docker 이미지 빌드
                script {
                    sh 'docker build -t ${REPOSITORY_URI}:${GIT_HASH} .'
                }
            }
        }
        
        stage('Push') {
            steps {
                // ECR 인증/이미지 푸시
                script {
                    sh 'aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/s8h8u3c8'
                    sh 'docker push ${REPOSITORY_URI}:${GIT_HASH}'
                    sh 'docker rmi ${REPOSITORY_URI}:${GIT_HASH}'
                }
            }
        }

        stage('Prepare Deploy') {
            steps {
                // taskdef.json 변경/업데이트
                script {
                    sh """
                        sed -e 's;%GIT_HASH%;${GIT_HASH};g' taskdef.json > \
                        taskdef-${GIT_HASH}.json

                        aws ecs register-task-definition --family ${TASK_NAME} --cli-input-json file://taskdef-${GIT_HASH}.json
                    """
                }
            }
        }
        
        // stage('Deploy') {
        //     steps {
        //         // ECS Fargate에 배포
        //         script {
        //             // 
        //             sh 'aws ecs create-cluster --cluster-name my-cluster'
        //             sh 'aws ecs create-service --service-name my-service --cluster my-cluster --launch-type FARGATE --task-definition my-task --desired-count 1 --network-configuration "awsvpcConfiguration={subnets=[subnet-xxxxxxxx],securityGroups=[sg-xxxxxxxx],assignPublicIp=ENABLED}"'
                    
        //             // 새로운 이미지로 태스크 정의 업데이트
        //             sh 'aws ecs update-service --service my-service --cluster my-cluster --task-definition my-task'
        //         }
        //     }
        // }
    }
}
