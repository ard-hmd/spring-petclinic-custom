resource "aws_codebuild_project" "build" {
    count = length(var.service_name)
    name = "petclinic-${var.service_name[count.index]}-deploy"
    source {
        type = "GITHUB"
        location = var.repo_source[count.index]
        buildspec = "buildspec-deploy.yml"
    }

    source_version = "refs/heads/master"

    environment {
        compute_type                = "BUILD_GENERAL1_SMALL"
        image                       = "aws/codebuild/amazonlinux2-x86_64-standard:corretto11-23.07.28"
        type                        = "LINUX_CONTAINER"
        image_pull_credentials_type = "CODEBUILD"
        privileged_mode             = true

        environment_variable {
          name  = "REPOSITORY_PREFIX"
          type  = "PLAINTEXT"
          value = var.repository_prefix
        }

        environment_variable {
          name  = "ENVIRONMENT"
          type  = "PLAINTEXT"
          value = var.repository_prefix
        }

        environment_variable {
          name  = "DOCKER_LOGIN"
          type  = "PARAMETER_STORE"
          value = "PETCLINIC_DOCKER_USERNAME"
        }

        environment_variable {
          name  = "DOCKER_PASSWORD"
          type  = "PARAMETER_STORE"
          value = "PETCLINIC_DOCKER_PASSWORD"
        }
    }

    artifacts {
        type = "NO_ARTIFACTS"
    }
    
    service_role = var.build_role_arn
}

resource "aws_codebuild_source_credential" "github_cred" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = var.github_token
}