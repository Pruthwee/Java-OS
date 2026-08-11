#!/bin/bash
set -e
set -o pipefail

PROJECT_NAME="openshift-java-demo"

echo "--- AWS EKS Deployment ---"
read -p "Enter AWS Region (e.g. us-east-1): " AWS_REGION
read -p "Enter EKS Cluster Name: " CLUSTER_NAME
read -p "Enter Full Docker Image URI (e.g. 123456789.dkr.ecr.us-east-1.amazonaws.com/repo:tag): " IMAGE_URI

echo "--- Application Configuration ---"
read -p "Enter SPRING_DATASOURCE_URL [jdbc:postgresql://tododb:5432/todo]: " SPRING_DATASOURCE_URL
SPRING_DATASOURCE_URL=${SPRING_DATASOURCE_URL:-jdbc:postgresql://tododb:5432/todo}

read -p "Enter SPRING_DATASOURCE_USERNAME [todo]: " SPRING_DATASOURCE_USERNAME
SPRING_DATASOURCE_USERNAME=${SPRING_DATASOURCE_USERNAME:-todo}

read -p "Enter SPRING_DATASOURCE_PASSWORD [demo123]: " SPRING_DATASOURCE_PASSWORD
SPRING_DATASOURCE_PASSWORD=${SPRING_DATASOURCE_PASSWORD:-demo123}

echo "Configuring kubectl..."
aws eks update-kubeconfig --region "$AWS_REGION" --name "$CLUSTER_NAME"

echo "Verifying cluster connectivity..."
kubectl cluster-info || { echo "Cluster connectivity failed"; exit 1; }

echo "Updating manifests..."
sed -i "s|{{IMAGE_URI}}|$IMAGE_URI|g" kubernetes/deployment.yaml
sed -i "s|{{SPRING_DATASOURCE_URL}}|$SPRING_DATASOURCE_URL|g" kubernetes/deployment.yaml
sed -i "s|{{SPRING_DATASOURCE_USERNAME}}|$SPRING_DATASOURCE_USERNAME|g" kubernetes/deployment.yaml
sed -i "s|{{SPRING_DATASOURCE_PASSWORD}}|$SPRING_DATASOURCE_PASSWORD|g" kubernetes/deployment.yaml

echo "Applying manifests..."
kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
kubectl apply -f kubernetes/ingress.yaml

echo "Waiting for rollout..."
kubectl rollout status deployment/$PROJECT_NAME -n $PROJECT_NAME

echo "Deployment complete. Verifying resources..."
kubectl get pods,svc,ingress -n $PROJECT_NAME

echo "Application should be accessible via the Ingress host defined in kubernetes/ingress.yaml"
