resource "aws_codebuild_project" "pipeline" {
    name = "petclinic-customers-pipeline"
    source {
        type = "CODECOMMIT"
        location = 
    }

    source_version = "master"
    
    environment {
        compute_type                = "BUILD_GENERAL1_SMALL"
        image                       = "aws/codebuild/amazonlinux2-x86_64-standard:corretto11-23.07.28"
        type                        = "LINUX_CONTAINER"
        image_pull_credentials_type = "CODEBUILD"

        environment_variable {
            name  = "CLUSTER_NAME"
            value = "PETCLINIC_EKS_CLUSTER_NAME"
            type = "PARAMETER_STORE"
        }

        environment_variable {
            name  = "DOCKER_LOGIN"
            value = "PETCLINIC_DOCKER_USERNAME"
            type = "PARAMETER_STORE"
        }

        environment_variable {
            name  = "DOCKER_PASSWORD"
            value = "PETCLINIC_DOCKER_PASSWORD"
            type = "PARAMETER_STORE"
        }

        environment_variable {
            name  = "REPOSITORY_PREFIX"
            value = "michelnguyenfr"
        }

        environment_variable {
            name  = "REPOSITORY_URI"
            value = "michelnguyenfr/spring-petclinic-cloud-customers-service"
        }

        environment_variable {
            name  = "TAG"
            value = "latest"
        }
    }

    artifacts {
        type = "NO_ARTIFACTS"
    }
    
    service_role = "arn:aws:iam::296615500438:role/service-role/codebuild-p-service-role"
}
