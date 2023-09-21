variable "build_role_arn" { type = string }
variable "github_token" { type = string }
variable "repository_prefix" {
    type = string
    default = "michelnguyenfr"
}
variable "name_prefix" {
  type        = list(string)
  default     = "petclinic-visits-deploy-"
}

variable "env" {
  type        = list(string)
  default     = ["dev", "qa", "prod"]
}

variable "source" {
  type = string
  default = "https://github.com/michelnguyenfr/spring-petclinic-visits.git"
}