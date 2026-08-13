@echo off
setlocal enabledelayedexpansion

set "PROJECT_NAME=openshift-java-demo"

echo Select Registry Type:
echo 1) AWS ECR
echo 2) Docker Hub
set /p REGISTRY_CHOICE="Choice [1-2]: "

if "%REGISTRY_CHOICE%"=="1" (
    set /p AWS_REGION="Enter AWS Region (e.g. us-east-1): "
    set /p ECR_REPO="Enter ECR Repository Name: "
    
    for /f "tokens=*" %%i in ('aws ecr describe-repositories --repository-names !ECR_REPO! --region !AWS_REGION! --query "repositories[0].repositoryUri" --output text 2^>nul') do set REGISTRY_URL=%%i
    
    if "!REGISTRY_URL!"=="" (
        echo Creating ECR repository !ECR_REPO!...
        aws ecr create-repository --repository-name !ECR_REPO! --region !AWS_REGION! >nul
        for /f "tokens=*" %%i in ('aws ecr describe-repositories --repository-names !ECR_REPO! --region !AWS_REGION! --query "repositories[0].repositoryUri" --output text') do set REGISTRY_URL=%%i
    )
    
    aws ecr get-login-password --region !AWS_REGION! | docker login --username AWS --password-stdin !REGISTRY_URL!
    if !ERRORLEVEL! neq 0 (echo ECR login failed & exit /b 1)
    set "FULL_REGISTRY=!REGISTRY_URL!"
) else (
    set /p DOCKER_USER="Enter Docker Hub Username: "
    set /p DOCKER_PASS="Enter Docker Hub Password: "
    echo !DOCKER_PASS! | docker login --username !DOCKER_USER! --password-stdin
    if !ERRORLEVEL! neq 0 (echo Docker Hub login failed & exit /b 1)
    set "FULL_REGISTRY=docker.io/!DOCKER_USER!"
)

set /p IMAGE_TAG="Enter Image Tag (default: latest): "
if "!IMAGE_TAG!"=="" set "IMAGE_TAG=latest"

set "IMAGE_NAME=%PROJECT_NAME%"
set "IMAGE_NAME=%IMAGE_NAME: =-%"
set "IMAGE_NAME=%IMAGE_NAME:A=a%"
set "IMAGE_NAME=%IMAGE_NAME:B=b%"
set "IMAGE_NAME=%IMAGE_NAME:C=c%"
set "IMAGE_NAME=%IMAGE_NAME:D=d%"
set "IMAGE_NAME=%IMAGE_NAME:E=e%"
set "IMAGE_NAME=%IMAGE_NAME:F=f%"
set "IMAGE_NAME=%IMAGE_NAME:G=g%"
set "IMAGE_NAME=%IMAGE_NAME:H=h%"
set "IMAGE_NAME=%IMAGE_NAME:I=i%"
set "IMAGE_NAME=%IMAGE_NAME:J=j%"
set "IMAGE_NAME=%IMAGE_NAME:K=k%"
set "IMAGE_NAME=%IMAGE_NAME:L=l%"
set "IMAGE_NAME=%IMAGE_NAME:M=m%"
set "IMAGE_NAME=%IMAGE_NAME:N=n%"
set "IMAGE_NAME=%IMAGE_NAME:O=o%"
set "IMAGE_NAME=%IMAGE_NAME:P=p%"
set "IMAGE_NAME=%IMAGE_NAME:Q=q%"
set "IMAGE_NAME=%IMAGE_NAME:R=r%"
set "IMAGE_NAME=%IMAGE_NAME:S=s%"
set "IMAGE_NAME=%IMAGE_NAME:T=t%"
set "IMAGE_NAME=%IMAGE_NAME:U=u%"
set "IMAGE_NAME=%IMAGE_NAME:V=v%"
set "IMAGE_NAME=%IMAGE_NAME:W=w%"
set "IMAGE_NAME=%IMAGE_NAME:X=x%"
set "IMAGE_NAME=%IMAGE_NAME:Y=y%"
set "IMAGE_NAME=%IMAGE_NAME:Z=z%"

set "FULL_IMAGE_NAME=!FULL_REGISTRY!/!IMAGE_NAME!:!IMAGE_TAG!"

echo Building image !FULL_IMAGE_NAME!...
docker build -t "!FULL_IMAGE_NAME!" .
if !ERRORLEVEL! neq 0 (echo Docker build failed & exit /b 1)

echo Pushing image !FULL_IMAGE_NAME!...
docker push "!FULL_IMAGE_NAME!"
if !ERRORLEVEL! neq 0 (echo Docker push failed & exit /b 1)

echo Successfully built and pushed !FULL_IMAGE_NAME!
