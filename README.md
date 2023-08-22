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
   git version
   ```
   sample output:
   ```
   {
     "clientVersion": {
       "major": "1",
       "minor": "27+",
       "gitVersion": "v1.27.1-eks-2f008fe",
       "gitCommit": "abfec7d7e55d56346a5259c9379dea9f56ba2926",
       "gitTreeState": "clean",
       "buildDate": "2023-04-14T20:43:13Z",
       "goVersion": "go1.20.3",
       "compiler": "gc",
       "platform": "linux/amd64"
     },
     "kustomizeVersion": "v5.0.1"
   }
   The connection to the server localhost:8080 was refused - did you specify the right host or port?

   0.153.0

   version.BuildInfo{Version:"v3.12.3", GitCommit:"3a31588ad33fe3b89af5a2a54ee1d25bfe6eaa5e", GitTreeState:"clean", GoVersion:"go1.20.7"}

   Docker version 20.10.25, build b82b9f3

   Apache Maven 3.2.5 (12a6b3acb947671f09b81f49094c53f426d8cea1; 2014-12-14T17:29:23+00:00)
   Maven home: /usr/share/apache-maven
   Java version: 17.0.8, vendor: Amazon.com Inc.
   Java home: /usr/lib/jvm/java-17-amazon-corretto.x86_64
   Default locale: en, platform encoding: UTF-8
   OS name: "linux", version: "6.1.41-63.114.amzn2023.x86_64", arch: "amd64", family: "unix"

   openjdk version "17.0.8" 2023-07-18 LTS
   OpenJDK Runtime Environment Corretto-17.0.8.7.1 (build 17.0.8+7-LTS)
   OpenJDK 64-Bit Server VM Corretto-17.0.8.7.1 (build 17.0.8+7-LTS, mixed mode, sharing)

   git version 2.40.1
   ```

2. Configure AWS CLI:
   ```bash
   aws configure
   ```
   sample output:
   ```
   AWS Access Key ID [None]: AKIAUKD5JLKLLOZVDYFZ
   AWS Secret Access Key [None]: tyFzc8TXQRlbNSZ9KHpRro2Z1pOsLQchFlxnZTLa
   Default region name [None]: eu-west-3
   Default output format [None]: json
   ```

3. Verify the connection:
   ```bash
   aws sts get-caller-identity
   ```
   sample output:
   ```
   {
    "UserId": "AIDAUKD5JLKLAWNVV3W66",
    "Account": "296615500439",
    "Arn": "arn:aws:iam::296615500439:user/username"
   }
   ```

## Cluster Configuration

1. Fetch the cluster configuration file from [this repository](https://github.com/ard-hmd/eksctl-cluster-config#usage) and follow the installation instructions provided there.

   sample output:
   ```
   [...]
   2023-08-22 13:17:15 [ℹ]  creating addon
   2023-08-22 13:18:54 [ℹ]  addon "aws-ebs-csi-driver" active
   2023-08-22 13:18:55 [ℹ]  kubectl command should work with "/home/ec2-user/.kube/config", try 'kubectl get nodes'
   2023-08-22 13:18:55 [✔]  EKS cluster "eks-test" in "eu-west-3" region is ready
   ```

3. Once the cluster and node group are set up, verify the installation:
   ```bash
   kubectl get nodes
   ```
   sample output:
   ```
   NAME                                            STATUS   ROLES    AGE   VERSION
   ip-192-168-119-222.eu-west-3.compute.internal   Ready    <none>   12m   v1.25.11-eks-a5565ad
   ip-192-168-76-36.eu-west-3.compute.internal     Ready    <none>   12m   v1.25.11-eks-a5565ad
   ```

4. Login to DockerHub
   ```bash
   docker login
   ```
   sample output:
   ```
   Login with your Docker ID to push and pull images from Docker Hub. If you don't have a Docker ID, head over to https://hub.docker.com to create one.
   Username: username
   Password:
   WARNING! Your password will be stored unencrypted in /home/ec2-user/.docker/config.json.
   Configure a credential helper to remove this warning. See
   https://docs.docker.com/engine/reference/commandline/login/#credentials-store
   
   Login Succeeded

   ```
   
## Application Deployment

1. Clone the repository:
   ```bash
   cd ~
   git clone git@github.com:username/spring-petclinic-custom.git
   cd spring-petclinic-custom
   ```
   
2. Build the Docker images:
   ```bash
   export REPOSITORY_PREFIX=<DOCKERHUB_LOGIN>
   mvn spring-boot:build-image -Pk8s -DREPOSITORY_PREFIX=${REPOSITORY_PREFIX}
   ```
   sample output:
   ```
   [INFO]
   [INFO] >>> spring-boot-maven-plugin:2.6.3:build-image (default-cli) > package @ spring-petclinic-cloud >>>
   [INFO]
   [INFO] <<< spring-boot-maven-plugin:2.6.3:build-image (default-cli) < package @ spring-petclinic-cloud <<<
   [INFO]
   [INFO] --- spring-boot-maven-plugin:2.6.3:build-image (default-cli) @ spring-petclinic-cloud ---
   [INFO] ------------------------------------------------------------------------
   [INFO] Reactor Summary:
   [INFO]
   [INFO] spring-petclinic-customers-service ................. SUCCESS [01:25 min]
   [INFO] spring-petclinic-vets-service ...................... SUCCESS [ 31.593 s]
   [INFO] spring-petclinic-visits-service .................... SUCCESS [ 27.851 s]
   [INFO] spring-petclinic-api-gateway ....................... SUCCESS [ 57.859 s]
   [INFO] spring-petclinic-cloud ............................. SUCCESS [  1.349 s]
   [INFO] ------------------------------------------------------------------------
   [INFO] BUILD SUCCESS
   [INFO] ------------------------------------------------------------------------
   [INFO] Total time: 03:29 min
   [INFO] Finished at: 2023-08-22T13:34:19+00:00
   [INFO] Final Memory: 152M/511M
   [INFO] ------------------------------------------------------------------------
   ```
   
3. Push the images to DockerHub:
   ```bash
   ./scripts/pushImages.sh
   ```
   sample output:
   ```
   [...]
   28791805c774: Pushed
   8812c86dc680: Mounted from username/spring-petclinic-cloud-vets-service
   5f70bf18a086: Mounted from username/spring-petclinic-cloud-vets-service
   d75a69a23e8d: Pushed
   [...]
   ```
   ![image](https://github.com/ard-hmd/spring-petclinic-custom/assets/138102964/39b0dd71-27d7-4a68-8d4a-e31857ebdf4d)


4. Deploy the Kubernetes resources:
   ```bash
   ./scripts/setup-k8s-resources.sh <REPOSITORY_PREFIX>
   ```
   sample output:
   ```
   [...]
   deployment.apps/visits-service created
   Waiting for 30 seconds to ensure others deployments are up and running...
   Try this following URL: http://a216f75db1c64409093ea5f954d5a1c5-782026288.eu-west-3.elb.amazonaws.com
   Deployment process completed!
   ```
   
5. Test the application by accessing the provided URL.
![image](https://github.com/ard-hmd/spring-petclinic-custom/assets/138102964/31180d98-2de0-43e6-873e-a1e87c095a0c)

7. View the deployed resources:
   ```bash
   kubectl get all -n spring-petclinic
   ```
   sample output:
   ```
   NAME                                    READY   STATUS    RESTARTS   AGE
   pod/api-gateway-69d7586b65-svt8z        1/1     Running   0          111s
   pod/customers-db-mysql-0                1/1     Running   0          3m23s
   pod/customers-service-f5dbf575d-zndjw   1/1     Running   0          111s
   pod/vets-db-mysql-0                     1/1     Running   0          3m29s
   pod/vets-service-5595fb9598-plvbr       1/1     Running   0          111s
   pod/visits-db-mysql-0                   1/1     Running   0          3m26s
   pod/visits-service-7bdb45f5f4-mjrns     1/1     Running   0          111s
   
   NAME                                  TYPE           CLUSTER-IP       EXTERNAL-IP                                                              PORT(S)        AGE
   service/api-gateway                   LoadBalancer   10.100.228.135   a216f75db1c64409093ea5f954d5a1c5-782026288.eu-west-3.elb.amazonaws.com   80:30136/TCP   3m41s
   service/customers-db-mysql            ClusterIP      10.100.115.206   <none>                                                                   3306/TCP       3m23s
   service/customers-db-mysql-headless   ClusterIP      None             <none>                                                                   3306/TCP       3m23s
   service/customers-service             ClusterIP      10.100.200.29    <none>                                                                   8080/TCP       3m41s
   service/vets-db-mysql                 ClusterIP      10.100.189.41    <none>                                                                   3306/TCP       3m29s
   service/vets-db-mysql-headless        ClusterIP      None             <none>                                                                   3306/TCP       3m29s
   service/vets-service                  ClusterIP      10.100.180.77    <none>                                                                   8080/TCP       3m41s
   service/visits-db-mysql               ClusterIP      10.100.229.250   <none>                                                                   3306/TCP       3m26s
   service/visits-db-mysql-headless      ClusterIP      None             <none>                                                                   3306/TCP       3m26s
   service/visits-service                ClusterIP      10.100.174.49    <none>                                                                   8080/TCP       3m41s
   
   NAME                                READY   UP-TO-DATE   AVAILABLE   AGE
   deployment.apps/api-gateway         1/1     1            1           111s
   deployment.apps/customers-service   1/1     1            1           111s
   deployment.apps/vets-service        1/1     1            1           111s
   deployment.apps/visits-service      1/1     1            1           111s
   
   NAME                                          DESIRED   CURRENT   READY   AGE
   replicaset.apps/api-gateway-69d7586b65        1         1         1       111s
   replicaset.apps/customers-service-f5dbf575d   1         1         1       111s
   replicaset.apps/vets-service-5595fb9598       1         1         1       111s
   replicaset.apps/visits-service-7bdb45f5f4     1         1         1       111s
   
   NAME                                  READY   AGE
   statefulset.apps/customers-db-mysql   1/1     3m23s
   statefulset.apps/vets-db-mysql        1/1     3m29s
   statefulset.apps/visits-db-mysql      1/1     3m26s
   ```
## Application Deletion

1. Delete the Kubernetes resources:
   ```bash
   ./scripts/cleanup-k8s-resources.sh <REPOSITORY_PREFIX>
   ```
   sample output:
   ```
   [...]
   service "visits-service" deleted
   Deleting initial namespace configuration...
   namespace "spring-petclinic" deleted
   Cleanup process completed!
   ```
## Cluster Deletion

1. Delete the entire EKS cluster
   ```bash
   eksctl delete cluster --name <nom-du-cluster>
   ```
   sample output:
   ```
   [...]
   2023-08-22 14:04:59 [ℹ]  deleted serviceaccount "kube-system/ebs-csi-controller-sa"
   2023-08-22 14:04:59 [ℹ]  deleted serviceaccount "kube-system/aws-node"
   2023-08-22 14:04:59 [ℹ]  will delete stack "eksctl-eks-test-cluster"
   2023-08-22 14:05:00 [✔]  all cluster resources were deleted
   ```
