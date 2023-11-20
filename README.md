# HelloKubeOps

This repository demonstrates an automated CI/CD pipeline using GitHub Actions for a simple 'Hello World' application. The application is containerized and deployed to Kubernetes, leveraging Github Actions, Docker Hub and ArgoCD.

## Repository Overview

- **Application:** The 'Hello World' app simply prints "Hello World - Version xxx" and stays idle without exiting.
- **Branches:** The repository is organized into two main branches: `main` for production and `staging` for staging environments.
- **Namespaces:** The production app runs in the 'hello-world' namespace, while the staging app runs in the 'hello-world-staging' namespace.

## GitHub Actions Setup

### Preliminary actions

- Grant write permissions to GitHub Actions for automated commits and tagging.
- Ensure the following GitHub secrets are set:
  - `DOCKER_HUB_USERNAME`: Your Docker Hub username.
  - `DOCKER_HUB_ACCESS_TOKEN`: Access token for Docker Hub to enable image push.

### Workflow

- **Trigger:** The GitHub Actions workflow is triggered by any push to the `main` branch that modifies the Dockerfile.
- **Function:** On each push:
  - Calculates the new version of the container (only increments PATCH version), based on the repository tag. The job increments only the PATCH version, I assume that major version changes are done manually. 
  - Pushes the new image version to DockerHub.
  - Updates the `deployment.yaml` with the new container version for Kubernetes deployment.
  - Commits the updated `deployment.yaml` back to the repository.
  - Increments the repository tag.

## K8s Deployment Strategy

- **Zero Downtime Deployment:**
  - `maxUnavailable: 0` ensures no downtime during pod replacement.
  - `maxSurge: 1` allows one additional pod during the update process.
- **Other Considerations not implemented:**
  - Readiness and liveness probes with an HTTP endpoint (e.g., `/health`) for enhanced reliability and monitoring.

## Argo CD Integration

### Project and Applications

- **Project:** A single Argo CD project for the repository.
- **Applications:** One per branch: Production (`main`) and Staging (`staging`).

### Synchronization with Argo CD

- **Automated Sync Policy:**
  - `prune: true` — Automatically delete resources removed from source.
  - `selfHeal: true` — Automatically correct drifts from the desired state.
- **Automatic Deployment:** Detects changes in `deployment.yaml` and synchronizes Kubernetes clusters.
- **K8s Namespaces:** Production deploys to `hello-world`, staging to `hello-world-staging`.