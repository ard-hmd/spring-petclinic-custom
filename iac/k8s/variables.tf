variable "namespace" {
  description = "Namespace for the ConfigMap"
  type        = string
  default     = "spring-petclinic" # Remplacez par le nom de votre namespace par défaut
}

variable "acm_certificate_arn" {
  description = "ARN du certificat AWS ACM"
  type        = string
  default     = "arn:aws:acm:eu-west-3:296615500438:certificate/8391ef57-98c5-478c-9a06-53f663bc01f6"
}

variable "repository_prefix" {
  description = "Repository to pull the image"
  type        = string
  default     = "ardhmd" # Remplacez par le nom de votre namespace par défaut
}

variable "customers_db_host" {
  description = "Adresse du serveur de base de données"
  type        = string
  default     = "customersdb.c6wqjjevzbkj.eu-west-3.rds.amazonaws.com"
}

variable "customers_db_name" {
  description = "Nom de la base de données"
  type        = string
  default     = "customersdb"
}

variable "vets_db_host" {
  description = "Hostname for the vets database"
  type        = string
  default     = "vetsdb.c6wqjjevzbkj.eu-west-3.rds.amazonaws.com"
}

variable "vets_db_name" {
  description = "Name of the vets database"
  type        = string
  default     = "vetsdb"
}


variable "visits_db_host" {
  description = "Hostname for the visits database"
  type        = string
  default     = "visitsdb.c6wqjjevzbkj.eu-west-3.rds.amazonaws.com"
}

variable "visits_db_name" {
  description = "Name of the visits database"
  type        = string
  default     = "visitsdb"
}

variable "visits_db_password" {
  description = "Mot de passe pour la base de données visits-db"
  type        = string
  sensitive   = true
}

variable "vets_db_password" {
  description = "Mot de passe pour la base de données vets-db"
  type        = string
  sensitive   = true
}

variable "customers_db_password" {
  description = "Mot de passe pour la base de données customers-db"
  type        = string
  sensitive   = true
}