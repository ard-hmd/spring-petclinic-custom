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

module "roles" {
  source = "./modules/roles"
  json_path = "./modules/role_build/build-policy.json"
}

module "codebuild_customers" {
  source = "./modules/codebuild_customers"
  build_role_arn = module.role_build.build_role_arn
  github_token = var.github_token
}

module "codebuild_visits" {
  source = "./modules/codebuild_visits"
  build_role_arn = module.role_build.build_role_arn
  github_token = var.github_token
}

module "codebuild_vets" {
  source = "./modules/codebuild_vets"
  build_role_arn = module.role_build.build_role_arn
  github_token = var.github_token
}

module "codebuild_api_gateway" {
  source = "./modules/codebuild_api_gateway"
  build_role_arn = module.role_build.build_role_arn
  github_token = var.github_token
}

module "codebuild_deploy" {
  source = "./modules/codebuild_deploy"
  build_role_arn = module.role_build.build_role_arn
  github_token = var.github_token
}

module "codepipeline" {
  source = "./modules/codepipeline"
  github_token = var.github_token
}