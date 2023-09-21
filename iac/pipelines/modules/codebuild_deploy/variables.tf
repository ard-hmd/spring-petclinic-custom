variable "build_role_arn" { type = string }
variable "github_token" { type = string }
variable "repository_prefix" {
    type = string
    default = "michelnguyenfr"
}

variable "service_name" {
  type    = list(string)
  default = ["api-gateway","customers","vets","visits"]
}

variable "repo_source" {
  type = list(string)
  default = [
    "https://github.com/michelnguyenfr/spring-petclinic-api-gateway.git",
    "https://github.com/michelnguyenfr/spring-petclinic-customers.git",
    "https://github.com/michelnguyenfr/spring-petclinic-vets.git",
    "https://github.com/michelnguyenfr/spring-petclinic-visits.git"
  ]
}

variable "environment" {
  type = string
  default = "dev"
}