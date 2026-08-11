@echo off
setlocal enabledelayedexpansion

set PROJECT_NAME=openshift-java-demo

echo Select Registry Type:
echo 1) AWS ECR
echo 2) Docker Hub
set /p REGISTRY_CHOICE="Choice [1-2]: "

if "%REGISTRY_CHOICE%"=="1" (
    set /p AWS_REGION="Enter AWS Region (e.g. us-east-1): "
    set /p ECR_REPO="Enter ECR Repository Name: "
    
    set "IMAGE_NAME=%PROJECT_NAME%"
    set "IMAGE_NAME=!IMAGE_NAME: =-!"
    
    set /p IMAGE_TAG="Enter Image Tag [latest]: "
    if "!IMAGE_TAG!"=="" set IMAGE_TAG=latest
    
    aws ecr describe-repositories --repository-names !ECR_REPO! --region !AWS_REGION! >nul 2>&1
    if !ERRORLEVEL! neq 0 (
        echo Creating ECR repository !ECR_REPO!...
        aws ecr create-repository --repository-name !ECR_REPO! --region !AWS_REGION!
    )
    
    set "REGISTRY_URL=aws ecr describe-repositories --repository-names !ECR_REPO! --region !AWS_REGION! --query repositories[0].repositoryUri --output text"
    for /f "tokens=*" %%i in ('aws ecr describe-repositories --repository-names !ECR_REPO! --region !AWS_REGION! --query "repositories[0].repositoryUri" --output text') do set REGISTRY_URL=%%i
    
    aws ecr get-login-password --region !AWS_REGION! | docker login --username AWS --password-stdin !REGISTRY_URL!
    if !ERRORLEVEL! neq 0 (
        echo ECR login failed & exit /b 1
    )
    set FULL_IMAGE_NAME=!REGISTRY_URL!:!IMAGE_TAG!
) else (
    set /p DOCKER_USER="Enter Docker Hub Username: "
    set /p DOCKER_PASS="Enter Docker Hub Password: "
    
    set "IMAGE_NAME=%PROJECT_NAME%"
    set "IMAGE_NAME=!IMAGE_NAME: =-!"
    
    set /p IMAGE_TAG="Enter Image Tag [latest]: "
    if "!IMAGE_TAG!"=="" set IMAGE_TAG=latest
    
    echo !DOCKER_PASS! | docker login --username !DOCKER_USER! --password-stdin
    if !ERRORLEVEL! neq 0 (
        echo Docker Hub login failed & exit /b 1
    )
    set FULL_IMAGE_NAME=docker.io/!DOCKER_USER!/!IMAGE_NAME!:!IMAGE_TAG!
)

echo Building Docker image: !FULL_IMAGE_NAME!...
docker build -t !FULL_IMAGE_NAME! .
if !ERRORLEVEL! neq 0 (
    echo Docker build failed & exit /b 1
)

echo Pushing Docker image...
docker push !FULL_IMAGE_NAME!
if !ERRORLEVEL! neq 0 (
    echo Docker push failed & exit /b 1
)

echo Successfully built and pushed !FULL_IMAGE_NAME!
