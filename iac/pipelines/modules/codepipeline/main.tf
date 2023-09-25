resource "aws_codepipeline" "example" {
  count = length(var.pipelines)

  name = var.pipelines[count.index].name
  role_arn = var.service_role  # Replace with your CodePipeline role ARN

  artifact_store {
    location = var.s3_bucket  # Replace with your S3 bucket name
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name = "SourceAction"
      category = "Source"
      owner = "ThirdParty"
      provider = "GitHub"
      version = "1"

      configuration = {
        Owner             = var.pipelines[count.index].github_owner
        Repo              = var.pipelines[count.index].github_repo
        Branch            = var.pipelines[count.index].branch
        OAuthToken        = var.github_token  # Replace with your GitHub OAuth token
        PollForSourceChanges = "true"
      }

      output_artifacts = ["SourceArtifact"]
    }
  }

  stage {
    name = "Build"
    action {
      name = "BuildAction"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      version = "1"

      configuration = {
        ProjectName = var.pipelines[count.index].build
      }

      input_artifacts = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]
    }
  }

  stage {
    name = "DeployDev"
    action {
      name = "DeployDevAction"
      category = "Deploy"
      owner = "AWS"
      provider = "CodeBuild"
      version = "1"

      configuration = {
        ProjectName = var.pipelines[count.index].deploy
        EnvironmentVariables = [
          {
            name = "ENVIRONMENT"
            type = "PLAINTEXT"
            value = "dev"
          }
        ]
      }

      input_artifacts = ["BuildArtifact"]
    }
  }

  stage {
    name = "DeployProd"
    action {
      name = "DeployProdAction"
      category = "Deploy"
      owner = "AWS"
      provider = "CodeBuild"
      version = "1"

      configuration = {
        ProjectName = var.pipelines[count.index].deploy
        EnvironmentVariables = [
          {
            name = "ENVIRONMENT"
            type = "PLAINTEXT"
            value = "prod"
          }
        ]
      }

      input_artifacts = ["BuildArtifact"]
    }
  }
}
