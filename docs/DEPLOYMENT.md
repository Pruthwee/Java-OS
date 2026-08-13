# Deployment Guide for openshift-java-demo on AWS EKS

## Prerequisites
- AWS Account with appropriate permissions
- AWS CLI installed and configured
- kubectl installed
- Docker installed and running
- EKS Cluster (or permissions to create one)

## Local Development Setup
1. Clone the repository.
2. Ensure you have a PostgreSQL database running locally or update `application.properties`.
3. Use Docker Compose for quick startup:
   ```bash
   docker-compose up --build
   ```

## Build and Push Image
1. Run the build script:
   - Linux/macOS: `./scripts/build-push.sh`
   - Windows: `scripts\build-push.bat`
2. Follow the prompts to select your registry (AWS ECR or Docker Hub).
3. The script will build the image and push it to the specified registry.

## AWS EKS Deployment
1. Ensure your AWS CLI is configured with the correct profile.
2. Run the deployment script:
   - Linux/macOS: `./scripts/deploy-image.sh`
   - Windows: `scripts\deploy-image.bat`
3. Provide the required information:
   - AWS Region
   - EKS Cluster Name
   - Docker Image URI (the one pushed in the previous step)
   - Database connection details (URL, Username, Password)

## Kubernetes Manifests Description
- `namespace.yaml`: Creates a dedicated namespace for the application.
- `deployment.yaml`: Defines the application pods, resource limits, and health probes.
- `service.yaml`: Exposes the application internally within the cluster.
- `ingress.yaml`: Configures the AWS Load Balancer to expose the application to the internet.

## Troubleshooting
- **Pod Failures**: Check logs using `kubectl logs -l app=openshift-java-demo -n openshift-java-demo`.
- **Health Check Failures**: Ensure the application is starting correctly and `/actuator/health` is accessible.
- **Ingress Issues**: Verify that the AWS Load Balancer Controller is installed in your EKS cluster.

## Configuration Management
The application uses Spring Boot profiles. The `docker` profile is activated by default in the container. Environment variables are used to override database settings in the EKS deployment.

## Security Considerations
- The container runs as a non-root user (`spring`).
- Resource limits are set to prevent memory leaks from affecting the node.
- Use AWS Secrets Manager or Kubernetes Secrets for sensitive data in production.
