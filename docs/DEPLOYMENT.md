# Deployment Guide - openshift-java-demo

This guide provides instructions for deploying the `openshift-java-demo` application to a local environment and AWS EKS.

## Prerequisites

### Local Development
- Docker
- Docker Compose

### AWS EKS Deployment
- AWS CLI configured with appropriate IAM permissions
- `kubectl` installed and configured
- An existing AWS EKS Cluster
- Docker installed for building and pushing images

## Local Development Setup

1. **Build and Run with Docker Compose**:
   ```bash
   docker-compose up --build
   ```
   The application will be available at `http://localhost:8080`.

## Build and Push to Registry

### Linux/macOS
```bash
chmod +x scripts/build-push.sh
./scripts/build-push.sh
```

### Windows
```cmd
scripts\\build-push.bat
```

The script will prompt you to choose between AWS ECR and Docker Hub and will handle the authentication and pushing of the image.

## AWS EKS Deployment

### 1. Prepare the Cluster
Ensure your AWS CLI is configured to the correct account and region.

### 2. Deploy the Application
Run the deployment script:

#### Linux/macOS
```bash
chmod +x scripts/deploy-image.sh
./scripts/deploy-image.sh
```

#### Windows
```cmd
scripts\\deploy-image.bat
```

The script will:
- Update your `kubeconfig` to point to the EKS cluster.
- Prompt for the Docker image URI and environment variables.
- Apply the Kubernetes manifests (Namespace, Deployment, Service, Ingress).
- Wait for the rollout to complete.

## Kubernetes Manifests Description

- `kubernetes/namespace.yaml`: Creates a dedicated namespace for the application.
- `kubernetes/deployment.yaml`: Defines the application pods, resource limits, and health probes.
- `kubernetes/service.yaml`: Exposes the application internally within the cluster.
- `kubernetes/ingress.yaml`: Configures the AWS Load Balancer to expose the application to the internet.

## Troubleshooting

### Pod Failures
Check pod logs:
```bash
kubectl logs -l app=openshift-java-demo -n openshift-java-demo
```
Describe the pod for events:
```bash
kubectl describe pod <pod-name> -n openshift-java-demo
```

### Service/Ingress Issues
Verify the service is targeting the correct pods:
```bash
kubectl get endpoints -n openshift-java-demo
```
Check the Ingress status:
```bash
kubectl describe ingress openshift-java-demo-ingress -n openshift-java-demo
```

## Configuration Management

The application uses Spring Boot profiles. The `docker` profile is active by default in the container. Environment variables are used to override database connections:
- `SPRING_DATASOURCE_URL`
- `SPRING_DATASOURCE_USERNAME`
- `SPRING_DATASOURCE_PASSWORD`

## Security Considerations
- The application runs as a non-root user (`appuser`) in the Docker image.
- Resource limits are set to prevent the application from consuming all cluster resources.
- Use AWS Secrets Manager or Kubernetes Secrets for sensitive data in production.
