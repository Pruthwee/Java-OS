@echo off
setlocal enabledelayedexpansion

set PROJECT_NAME=openshift-java-demo

echo --- AWS EKS Deployment ---
set /p AWS_REGION="Enter AWS Region (e.g. us-east-1): "
set /p CLUSTER_NAME="Enter EKS Cluster Name: "
set /p IMAGE_URI="Enter Full Docker Image URI (e.g. 123456789.dkr.ecr.us-east-1.amazonaws.com/repo:tag): "

echo --- Application Configuration ---
set /p SPRING_DATASOURCE_URL="Enter SPRING_DATASOURCE_URL [jdbc:postgresql://tododb:5432/todo]: "
if "!SPRING_DATASOURCE_URL!"=="" set SPRING_DATASOURCE_URL=jdbc:postgresql://tododb:5432/todo

set /p SPRING_DATASOURCE_USERNAME="Enter SPRING_DATASOURCE_USERNAME [todo]: "
if "!SPRING_DATASOURCE_USERNAME!"=="" set SPRING_DATASOURCE_USERNAME=todo

set /p SPRING_DATASOURCE_PASSWORD="Enter SPRING_DATASOURCE_PASSWORD [demo123]: "
if "!SPRING_DATASOURCE_PASSWORD!"=="" set SPRING_DATASOURCE_PASSWORD=demo123

echo Configuring kubectl...
aws eks update-kubeconfig --region !AWS_REGION! --name !CLUSTER_NAME!

echo Verifying cluster connectivity...
kubectl cluster-info
if !ERRORLEVEL! neq 0 (
    echo Cluster connectivity failed & exit /b 1
)

echo Updating manifests...
powershell -Command "(gc kubernetes/deployment.yaml) -replace '{{IMAGE_URI}}', '!IMAGE_URI!' -replace '{{SPRING_DATASOURCE_URL}}', '!SPRING_DATASOURCE_URL!' -replace '{{SPRING_DATASOURCE_USERNAME}}', '!SPRING_DATASOURCE_USERNAME!' -replace '{{SPRING_DATASOURCE_PASSWORD}}', '!SPRING_DATASOURCE_PASSWORD!' | Out-File -encoding utf8 kubernetes/deployment.yaml"

echo Applying manifests...
kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
kubectl apply -f kubernetes/ingress.yaml

echo Waiting for rollout...
kubectl rollout status deployment/!PROJECT_NAME! -n !PROJECT_NAME!

echo Deployment complete. Verifying resources...
kubectl get pods,svc,ingress -n !PROJECT_NAME!

echo Application should be accessible via the Ingress host defined in kubernetes/ingress.yaml
