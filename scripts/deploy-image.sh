#!/bin/bash
set -e
set -o pipefail

PROJECT_NAME="openshift-java-demo"

echo "--- AWS EKS Deployment ---"
read -p "Enter AWS Region: " AWS_REGION
read -p "Enter EKS Cluster Name: " CLUSTER_NAME
read -p "Enter Docker Image URI (e.g., <account>.dkr.ecr.<region>.amazonaws.com/repo:tag): " IMAGE_URI

# Application specific environment variables
read -p "Enter value for SPRING_DATASOURCE_URL (or press Enter to skip): " SPRING_DATASOURCE_URL
read -p "Enter value for SPRING_DATASOURCE_USERNAME (or press Enter to skip): " SPRING_DATASOURCE_USERNAME
read -p "Enter value for SPRING_DATASOURCE_PASSWORD (or press Enter to skip): " SPRING_DATASOURCE_PASSWORD

# Update manifests
sed -i "s|{{IMAGE_URI}}|$IMAGE_URI|g" kubernetes/deployment.yaml
sed -i "s|{{SPRING_DATASOURCE_URL}}|$SPRING_DATASOURCE_URL|g" kubernetes/deployment.yaml
sed -i "s|{{SPRING_DATASOURCE_USERNAME}}|$SPRING_DATASOURCE_USERNAME|g" kubernetes/deployment.yaml
sed -i "s|{{SPRING_DATASOURCE_PASSWORD}}|$SPRING_DATASOURCE_PASSWORD|g" kubernetes/deployment.yaml

echo "Configuring kubectl..."
aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME

echo "Verifying cluster connectivity..."
kubectl cluster-info || { echo "Cluster connectivity failed"; exit 1; }

echo "Applying manifests..."
kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
kubectl apply -f kubernetes/ingress.yaml

echo "Waiting for rollout..."
kubectl rollout status deployment/$PROJECT_NAME -n $PROJECT_NAME

echo "Verifying resources..."
kubectl get pods,svc,ingress -n $PROJECT_NAME

echo "Deployment complete. Application should be accessible via the Ingress URL."
