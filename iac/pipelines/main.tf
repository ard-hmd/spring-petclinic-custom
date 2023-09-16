terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
  access_key = var.access_key # la clé d’accès crée pour l'utilisateur qui sera utilisé par terraform
  secret_key = var.secret_key # la clé sécrète crée pour l'utilisateur qui sera utilisé par terraform
}

module "role_build" {
  source = "./modules/role_build"
  json_path = "./modules/role_build/customers-build-policy.json"
}

module "codebuild_customers" {
  source = "./modules/codebuild_customers"
  build_role_arn = module.role_build.build_role_arn
}

module "codebuild_visits" {
  source = "./modules/codebuild_visits"
  build_role_arn = module.role_build.build_role_arn
}

module "codebuild_vets" {
  source = "./modules/codebuild_vets"
  build_role_arn = module.role_build.build_role_arn
}

module "codebuild_api_gateway" {
  source = "./modules/codebuild_api_gateway"
  build_role_arn = module.role_build.build_role_arn
}
