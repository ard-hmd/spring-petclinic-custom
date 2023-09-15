resource "aws_codebuild_project" "pipeline" {
    name = "petclinic-customers-pipeline"
    source {
        type = "CODECOMMIT"
        location = "https://git-codecommit.eu-west-3.amazonaws.com/v1/repos/petclinic-customers"
    }

    source_version = "master"
    
    environment {
        compute_type                = "BUILD_GENERAL1_SMALL"
        image                       = "aws/codebuild/amazonlinux2-x86_64-standard:corretto11-23.07.28"
        type                        = "LINUX_CONTAINER"
        image_pull_credentials_type = "CODEBUILD"
    }

    artifacts {
        type = "NO_ARTIFACTS"
    }
    
    service_role = "arn:aws:iam::296615500438:role/service-role/codebuild-p-service-role"
}