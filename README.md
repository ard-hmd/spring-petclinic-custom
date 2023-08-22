# Distributed version of the Spring PetClinic - adapted for Kubernetes 

This project is a private fork of the [spring-petclinic-cloud](https://github.com/spring-petclinic/spring-petclinic-cloud/tree/master) repository. I've taken the original content and tailored it to fit my specific requirements.

## Modifications Made

- **Wavefront Commentary**: The Wavefront section in the Kubernetes deployment has been commented out to prevent its activation during deployment.
- **Deployment and Deletion Script**: A script has been introduced to streamline both the deployment and deletion processes of the application.
- **Service Directory Cleanup**: Directories of services that weren't utilized in the cloud-adapted version have been removed to simplify the project's structure.
- **Script Update**: The pushImages.sh script has been updated to automate the Docker image push to the registry.

## Prerequisites

*Details of the prerequisites needed for deploying and running the application will be provided later.*

## Compiling and pushing to Kubernetes

Deploying to Kubernetes can be a bit intricate since it involves managing Docker images, exposing services, and handling more YAML configurations. But with the right steps, it's manageable!

### Choose your Docker registry

Before deploying, you need to specify your target Docker registry. Ensure you're already logged in by executing `docker login <endpoint>` or simply `docker login` if you're aiming for Docker Hub.

Set up an environment variable to point to your Docker registry. If you're targeting Docker Hub, just provide your username, for example:

```bash
export REPOSITORY_PREFIX=odedia
