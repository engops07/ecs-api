pipeline {
    agent any
    
    options {
        timeout(time: 1, unit: 'HOURS') // set timeout 1 hour
    }
    
    environment {   // 전역 변수
        REPOSITORY_URI = 'public.ecr.aws/s8h8u3c8/api'  // ECR 레포지토리 URI
        PROJECT_NAME = 'api'                            // 공통 (ECS 클러스터, ECR 레포지토리, Jenkins JobName)
        CLUSTER_NAME = 'fastapi'                        // ECS 클러스터
        SERVICE_NAME = 'example'                        // example
        TASK_NAME = 'sample'                            // sample
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
                    // gitcommit number -> build / imagename 
                    def gitCommit = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
                    sh "docker build -t ${REPOSITORY_URI}:${gitCommit} ."
                }
            }
        }
        
        stage('Push') {
            steps {
                // ECR 인증/이미지 푸시
                script {
                    def gitCommit = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
                    sh "docker login -u AWS -p \$(aws ecr-public get-login-password --region us-east-1) public.ecr.aws/s8h8u3c8"
                    sh "docker push ${REPOSITORY_URI}:${gitCommit}"
                }
            }
        }

        stage('Prepare Deploy') {
            steps {
                // taskdef.json 변경/업데이트
                script {
                    def gitCommit = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
                    sh "sed -e 's;%GIT_HASH%;${gitCommit};g' taskdef.json > taskdef-${gitCommit}.json"
                    sh "aws ecs register-task-definition --family ${TASK_NAME} --cli-input-json file://taskdef-${gitCommit}.json"
                }
            }
        }
        
        stage('Deploy') {
            steps {
                // ECS Fargate에 배포
                script {
                    // 
                    def TASK_REVISION = sh(returnStdout: true, script: "aws ecs describe-task-definition --task-definition ${TASK_NAME} | egrep 'revision' | awk '{print \$2}'").trim().replace(",","")
                    sh "aws ecs update-service --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME} --task-definition ${TASK_NAME}:${TASK_REVISION}"
                }
            }
        }
    }
}
