# Deployment Guide - openshift-java-demo

This guide provides instructions for containerizing and deploying the `openshift-java-demo` application to AWS EKS.

## Prerequisites

### Local Development
- Docker installed and running
- Java 8 JDK
- Maven 3.8+

### AWS EKS Deployment
- AWS CLI installed and configured
- `kubectl` installed
- Access to an AWS EKS Cluster
- IAM permissions to create ECR repositories and manage EKS resources

## Local Development Setup

### Using Docker Compose
1. Create a `.env` file or set environment variables:
   ```bash
   export DB_HOST=your-db-host
   export DB_USER=your-db-user
   export DB_PASS=your-db-password
   ```
2. Run the application:
   ```bash
   docker-compose up --build
   ```
3. The application will be available at `http://localhost:8080`.

## Build and Push Instructions

### Linux/macOS
```bash
chmod +x scripts/build-push.sh
./scripts/build-push.sh
```

### Windows
```cmd
scripts\build-push.bat
```

The script will prompt you to choose between AWS ECR and Docker Hub, and will handle image tagging and pushing.

## AWS EKS Deployment Walkthrough

### 1. Configure kubectl
The deployment script handles this, but manually you can run:
```bash
aws eks update-kubeconfig --region <region> --name <cluster-name>
```

### 2. Deploy the Application
Run the deployment script:

**Linux/macOS:**
```bash
chmod +x scripts/deploy-image.sh
./scripts/deploy-image.sh
```

**Windows:**
```cmd
scripts\deploy-image.bat
```

### 3. Manifest Descriptions
- `namespace.yaml`: Creates a dedicated namespace `openshift-java-demo`.
- `deployment.yaml`: Manages the application pods, including resource limits and health probes.
- `service.yaml`: Exposes the application internally within the cluster.
- `ingress.yaml`: Configures the AWS Load Balancer to route external traffic to the service.

## Troubleshooting

### Pod Failures
- Check logs: `kubectl logs -l app=openshift-java-demo -n openshift-java-demo`
- Describe pod: `kubectl describe pod <pod-name> -n openshift-java-demo`

### Service/Ingress Issues
- Verify service: `kubectl get svc -n openshift-java-demo`
- Verify ingress: `kubectl get ingress -n openshift-java-demo`

### Rollback
If a deployment fails, you can roll back to the previous version:
```bash
kubectl rollout undo deployment/openshift-java-demo -n openshift-java-demo
```

## Configuration Management
The application uses Spring Boot profiles. The `docker` profile is activated by default in the container. Environment variables are used to override database settings:
- `SPRING_DATASOURCE_URL`
- `SPRING_DATASOURCE_USERNAME`
- `SPRING_DATASOURCE_PASSWORD`

## Security Considerations
- The container runs as a non-root user (UID 1001).
- Resource limits are enforced to prevent noisy neighbor issues.
- Use AWS Secrets Manager or Kubernetes Secrets for sensitive data in production.
