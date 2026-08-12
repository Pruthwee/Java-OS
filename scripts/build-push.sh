#!/bin/bash
set -e

PROJECT_NAME="openshift-java-demo"

echo "--- Docker Build and Push Script ---"
read -p "Enter IMAGE_TAG (default: latest): " IMAGE_TAG
IMAGE_TAG=${IMAGE_TAG:-latest}

echo "Select Registry:"
echo "1) AWS ECR"
echo "2) Docker Hub"
read -p "Choice [1-2]: " REGISTRY_CHOICE

if [ "$REGISTRY_CHOICE" == "1" ]; then
    read -p "Enter AWS Region (e.g., us-east-1): " AWS_REGION
    read -p "Enter ECR Repository Name: " ECR_REPO
    
    # Sanitize image name
    IMAGE_NAME=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-' | sed 's/^-*//;s/-*$//')
    REGISTRY_URL=$(aws ecr describe-repositories --repository-names "$ECR_REPO" --region "$AWS_REGION" --query 'repositories[0].repositoryUri' --output text 2>/dev/null || echo "")
    
    if [ -z "$REGISTRY_URL" ]; then
        echo "Creating ECR repository $ECR_REPO..."
        aws ecr create-repository --repository-name "$ECR_REPO" --region "$AWS_REGION" > /dev/null
        REGISTRY_URL=$(aws ecr describe-repositories --repository-names "$ECR_REPO" --region "$AWS_REGION" --query 'repositories[0].repositoryUri' --output text)
    fi

    echo "Logging into ECR..."
    aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$REGISTRY_URL"
    
    FULL_IMAGE_NAME="$REGISTRY_URL:$IMAGE_TAG"
else
    read -p "Enter Docker Hub Username: " DOCKER_USERNAME
    read -p "Enter Docker Hub Password: " -s DOCKER_PASSWORD
    echo ""
    
    echo "Logging into Docker Hub..."
    echo "$DOCKER_PASSWORD" | docker login --username "$DOCKER_USERNAME" --password-stdin
    
    IMAGE_NAME=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-' | sed 's/^-*//;s/-*$//')
    FULL_IMAGE_NAME="$DOCKER_USERNAME/$IMAGE_NAME:$IMAGE_TAG"
fi

echo "Building Docker image: $FULL_IMAGE_NAME..."
docker build -t "$FULL_IMAGE_NAME" .

echo "Pushing Docker image..."
docker push "$FULL_IMAGE_NAME"

echo "Successfully built and pushed $FULL_IMAGE_NAME"
