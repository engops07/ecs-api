#!/usr/bin/env groovy

def call() {
    def TASK_DEFINITION = sh (returnStdout: true, script: "aws ecs describe-task-definition --task-definition ${PROJECT_NAME}-${DEPLOY_ENV} | egrep 'taskDefinitionArn' | tr ',' ' ' | awk '{print \$2}' | tr '\"' ' '").trim()

    sh """
    sed -i 's;%GIT_HASH%;${GIT_HASH};g' create-deployment.json
    sed -i 's;<TASK_DEFINITION>;${TASK_DEFINITION};g' appspec.yml
    aws s3 cp appspec.yml s3://groobee-ecs-codedeploy/${PROJECT_NAME}/appspec-${GIT_HASH}.yml
    aws deploy create-deployment --cli-input-json file://create-deployment.json
    """
}
