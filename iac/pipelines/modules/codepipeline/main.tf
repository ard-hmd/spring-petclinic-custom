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

  # Add more stages and actions as needed (e.g., Build, Deploy)
  # Make sure to reference the corresponding index in the var.pipelines list
}
