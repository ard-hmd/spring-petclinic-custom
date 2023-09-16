resource "aws_iam_role" "build_role" {
  name                = "petclinic-customer-build-role"
  assume_role_policy  = "
    statement {
      effect = "Allow"

      principals {
        type        = "Service"
        identifiers = ["codebuild.amazonaws.com"]
      }

      actions = ["sts:AssumeRole"]
    }
  "

  tags = {
    tag-key = "terraform-petclinic-build-role"
  }
}

resource "aws_iam_policy" "build_policy" {
  name        = "petclinic-build-policy"
  description = "Policy to be used by the petclinic CodeBuild pipelines"
  policy = file(var.json_path)
  tags = {
    tag-key = "terraform-petclinic-build-policy"
  }
} 

resource "aws_iam_role_policy_attachment" "petclinic-build-role-policy-attachment" {
  role = aws_iam_role.build_role.name
  policy_arn = aws_iam_policy.build_policy.arn
}

