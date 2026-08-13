@echo off
setlocal enabledelayedexpansion

set "PROJECT_NAME=openshift-java-demo"

echo --- AWS EKS Deployment ---
set /p AWS_REGION="Enter AWS Region (e.g. us-east-1): "
set /p CLUSTER_NAME="Enter EKS Cluster Name: "
set /p IMAGE_URI="Enter Full Docker Image URI: "

echo --- Application Configuration ---
set /p SPRING_DATASOURCE_URL="Enter SPRING_DATASOURCE_URL (or press Enter to skip): "
set /p SPRING_DATASOURCE_USERNAME="Enter SPRING_DATASOURCE_USERNAME (or press Enter to skip): "
set /p SPRING_DATASOURCE_PASSWORD="Enter SPRING_DATASOURCE_PASSWORD (or press Enter to skip): "

echo Updating manifests...
powershell -Command "(gc kubernetes/deployment.yaml) -replace '{{IMAGE_URI}}', '%IMAGE_URI%' | Out-File -encoding ASCII kubernetes/deployment.yaml"
powershell -Command "(gc kubernetes/deployment.yaml) -replace '{{SPRING_DATASOURCE_URL}}', '%SPRING_DATASOURCE_URL%' | Out-File -encoding ASCII kubernetes/deployment.yaml"
powershell -Command "(gc kubernetes/deployment.yaml) -replace '{{SPRING_DATASOURCE_USERNAME}}', '%SPRING_DATASOURCE_USERNAME%' | Out-File -encoding ASCII kubernetes/deployment.yaml"
powershell -Command "(gc kubernetes/deployment.yaml) -replace '{{SPRING_DATASOURCE_PASSWORD}}', '%SPRING_DATASOURCE_PASSWORD%' | Out-File -encoding ASCII kubernetes/deployment.yaml"

echo Configuring kubectl...
aws eks update-kubeconfig --region %AWS_REGION% --name %CLUSTER_NAME%

echo Verifying cluster connectivity...
kubectl cluster-info
if %ERRORLEVEL% neq 0 (echo Cluster connectivity failed & exit /b 1)

echo Applying manifests...
kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
kubectl apply -f kubernetes/ingress.yaml

echo Waiting for rollout...
kubectl rollout status deployment/%PROJECT_NAME% -n %PROJECT_NAME%

echo Verifying resources...
kubectl get pods,svc,ingress -n %PROJECT_NAME%

echo --- Deployment Complete ---
echo Application URL: http://openshift-java-demo.example.com
echo If deployment failed, use: kubectl rollout undo deployment/%PROJECT_NAME% -n %PROJECT_NAME%
