variable "pipelines" {
  default = [
    {
      name          = "pipeline-customers"
      github_owner  = "michelnguyenfr"
      github_repo   = "spring-petclinic-customers"
      branch        = "main"
      build         = "petclinic-customers-build"
      deploy        = "petclinic-customers-deploy"
    },
    {
      name          = "pipeline-visits"
      github_owner  = "michelnguyenfr"
      github_repo   = "spring-petclinic-visits"
      branch        = "main"
      build         = "petclinic-visits-build"
      deploy        = "petclinic-visits-deploy"
    },
    {
      name          = "pipeline-vets"
      github_owner  = "michelnguyenfr"
      github_repo   = "spring-petclinic-vets"
      branch        = "main"
      build         = "petclinic-vets-build"
      deploy        = "petclinic-vets-deploy"
    },
    {
      name          = "pipeline-api-gateway"
      github_owner  = "michelnguyenfr"
      github_repo   = "spring-petclinic-api-gateway"
      branch        = "main"
      build         = "petclinic-api-gateway-build"
      deploy        = "petclinic-api-gateway-deploy"
    }
  ]
}

variable "s3_bucket" {
    type = string
    default= "codepipeline-eu-west-3-775846151645"
}

variable "service_role" {
    type = string
    default = "arn:aws:iam::296615500438:role/service-role/AWSCodePipelineServiceRole-eu-west-3-petclinic-customers"
}

variable "github_token" { type = string }