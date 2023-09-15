resource "aws_iam_role" "build_role" {
  name = "petclinic-customer-build-role"
  assume_role_policy = file("customers-build-policy.json")

  tags = {
    tag-key = "terraform-petclinic-build-role"
  }
}