resource "aws_codebuild_project" "build" {
    name = "petclinic-vets-build"
    source {
        type = "CODECOMMIT"
        location = "https://git-codecommit.eu-west-3.amazonaws.com/v1/repos/petclinic-vets"
    }

    source_version = "refs/heads/master"
    
    environment {
        compute_type                = "BUILD_GENERAL1_SMALL"
        image                       = "aws/codebuild/amazonlinux2-x86_64-standard:corretto11-23.07.28"
        type                        = "LINUX_CONTAINER"
        image_pull_credentials_type = "CODEBUILD"
        privileged_mode             = true
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