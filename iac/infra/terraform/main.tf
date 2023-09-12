module "aws_vpc" {
    source          = "github.com/ard-hmd/terraform-aws-vpc.git"
    vpc_cidr        = var.vpc_cidr
    environment     = var.environment
}
