# Deployment Guide for openshift-java-demo on AWS EKS

## Prerequisites
- Java 8 JDK
- Maven 3.8+
- Docker installed and running
- AWS CLI installed and configured
- kubectl installed
- Access to an AWS EKS Cluster

## Local Development Setup
1. Clone the repository.
2. Use Docker Compose for local testing:
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
scripts\build-push.bat
```
Follow the prompts to select between AWS ECR and Docker Hub.

## AWS EKS Deployment
### 1. EKS Cluster Setup
Ensure your EKS cluster is running and you have the necessary IAM permissions to manage it.

### 2. Deploy the Image
Use the deployment scripts to configure and apply Kubernetes manifests:
#### Linux/macOS
```bash
chmod +x scripts/deploy-image.sh
./scripts/deploy-image.sh
```
#### Windows
```cmd
scripts\deploy-image.bat
```

### 3. Manifests Description
- `namespace.yaml`: Creates a dedicated namespace for the application.
- `deployment.yaml`: Defines the application pods, resource limits, and health probes.
- `service.yaml`: Exposes the application internally within the cluster.
- `ingress.yaml`: Configures the AWS Load Balancer to expose the application to the internet.

## Troubleshooting
- **Pod Failures**: Check logs using `kubectl logs -l app=openshift-java-demo -n openshift-java-demo`.
- **Health Check Failures**: Ensure the application is starting correctly and `/actuator/health` is accessible.
- **Ingress Issues**: Verify that the AWS Load Balancer Controller is installed in your EKS cluster.

## Configuration Management
The application uses Spring profiles. The `docker` profile is active by default in the container. Environment variables are used to override database settings:
- `SPRING_DATASOURCE_URL`
- `SPRING_DATASOURCE_USERNAME`
- `SPRING_DATASOURCE_PASSWORD`

## Security Considerations
- The container runs as a non-root user (`spring`).
- Use AWS Secrets Manager or Kubernetes Secrets for sensitive data in production.
- Resource limits are set to prevent a single pod from consuming all node resources.
