#!/bin/bash
set -e
set -o pipefail

PROJECT_NAME="openshift-java-demo"

echo "--- AWS EKS Deployment Script ---"
read -p "Enter AWS Region (e.g., us-east-1): " AWS_REGION
read -p "Enter EKS Cluster Name: " CLUSTER_NAME
read -p "Enter Full Docker Image URI (e.g., 123456789.dkr.ecr.us-east-1.amazonaws.com/repo:latest): " IMAGE_URI

echo "--- Application Configuration ---"
read -p "Enter SPRING_DATASOURCE_URL (or press Enter to skip): " SPRING_DATASOURCE_URL
read -p "Enter SPRING_DATASOURCE_USERNAME (or press Enter to skip): " SPRING_DATASOURCE_USERNAME
read -p "Enter SPRING_DATASOURCE_PASSWORD (or press Enter to skip): " SPRING_DATASOURCE_PASSWORD

# Update manifests
sed -i "s|{{IMAGE_URI}}|$IMAGE_URI|g" kubernetes/deployment.yaml
sed -i "s|{{SPRING_DATASOURCE_URL}}|$SPRING_DATASOURCE_URL|g" kubernetes/deployment.yaml
sed -i "s|{{SPRING_DATASOURCE_USERNAME}}|$SPRING_DATASOURCE_USERNAME|g" kubernetes/deployment.yaml
sed -i "s|{{SPRING_DATASOURCE_PASSWORD}}|$SPRING_DATASOURCE_PASSWORD|g" kubernetes/deployment.yaml

echo "Configuring kubectl..."
aws eks update-kubeconfig --region "$AWS_REGION" --name "$CLUSTER_NAME"

echo "Verifying cluster connectivity..."
kubectl cluster-info || { echo "Cluster connectivity failed"; exit 1; }

echo "Applying Kubernetes manifests..."
kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
kubectl apply -f kubernetes/ingress.yaml

echo "Waiting for rollout..."
kubectl rollout status deployment/$PROJECT_NAME -n $PROJECT_NAME

echo "Verifying resources..."
kubectl get pods,svc,ingress -n $PROJECT_NAME

echo "Deployment complete. Application should be accessible via the Ingress URL."
