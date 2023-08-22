# Distributed version of the Spring PetClinic - adapted for Elastic Kubernetes Service

This project is a private fork of the [spring-petclinic-cloud](https://github.com/spring-petclinic/spring-petclinic-cloud/tree/master) repository. I've taken the original content and tailored it to fit my specific requirements.

## Modifications Made

- **Wavefront**: The Wavefront section in the Kubernetes deployment has been commented out to prevent its activation during deployment.
- **Deployment and Deletion Script**: A script has been introduced to streamline both the deployment and deletion processes of the application.
- **Service Directory Cleanup**: Directories of services that weren't utilized in the cloud-adapted version have been removed to simplify the project's structure.
- **Script Update**: The scripts has been updated to build and push only the required Docker images to the registry.

# Spring PetClinic on Kubernetes

## Prerequisites

Before you begin, ensure you have the following prerequisites installed on your machine:

- **IAM User**: An IAM user with programmatic access.
- **kubectl**: [Installation Guide](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html)
- **eksctl**: [Installation Guide](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html)
- **helm**: [Installation Guide](https://helm.sh/docs/intro/install/)
- **docker**: [Installation Guide](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-docker.html)
- **maven**: [Installation Guide](https://docs.aws.amazon.com/neptune/latest/userguide/iam-auth-connect-prerq.html)
- **java**: [Installation Guide](https://linux.how2shout.com/how-to-install-java-on-amazon-linux-2023/)
- **git**: [Installation Guide](https://git-scm.com/download/linux)

Ensure all these prerequisites are installed on your machine. When creating the client AMI, you can use the script from [this link](https://github.com/ard-hmd/spring-petclinic-custom/blob/3f6c0fd26308561df623c605dc87047490392dee/scripts/setup_k8s_tools.sh) as userdata. Make sure to check for the latest versions.

## Initial Setup

1. **Connect to your machine** and verify the installation of the packages:

   ```bash
   kubectl version --output=json
   eksctl version
   helm version
   docker --version
   mvn --version
   java -version

2. Configure AWS CLI:
   ```bash
   aws configure

3. Verify the connection:
   ```bash
   aws sts get-caller-identity

## Cluster Configuration

1. Fetch the cluster configuration file from [this repository](https://github.com/ard-hmd/eksctl-cluster-config#usage) and follow the installation instructions provided there.

2. Once the cluster and node group are set up, verify the installation:
   ```bash
   kubectl get nodes

3. Login to DockerHub
   ```bash
   docker login

## Application Deployment

1. Clone the repository:
   ```bash
   cd ~
   git clone git@github.com:ard-hmd/spring-petclinic-custom.git
   cd spring-petclinic-custom

2. Build the Docker images:
   ```bash
   export REPOSITORY_PREFIX=<DOCKERHUB_LOGIN>
   mvn spring-boot:build-image -Pk8s -DREPOSITORY_PREFIX=${REPOSITORY_PREFIX}

3. Push the images to DockerHub:
   ```bash
   ./scripts/pushImages.sh

4. Deploy the Kubernetes resources:
   ```bash
   ./scripts/setup-k8s-resources.sh

5. Test the application by accessing the provided URL.

7. View the deployed resources:
   ```bash
   kubectl get all -n spring-petclinic
