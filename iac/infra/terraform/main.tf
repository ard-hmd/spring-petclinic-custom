module "aws_vpc" {
    source          = "github.com/ard-hmd/terraform-aws-vpc.git"
    vpc_cidr        = var.vpc_cidr
    environment     = var.environment
}

module "rds_instances" {
  source       = "github.com/ard-hmd/terraform-aws-rds.git"
  aws_region   = var.aws_region
  database_configurations = [
    {
      identifier              = "my-db-1"
      allocated_storage       = 10
      engine_version          = "5.7"
      instance_class          = "db.t3.micro"
      db_name                 = "mydatabase1"
      db_username             = "admin1"
      db_password             = "password1"
      parameter_group_name    = "default.mysql5.7"
      db_subnet_group_name    = module.aws_vpc.rds_subnet_group_name
      skip_final_snapshot     = true
      publicly_accessible     = false
      backup_retention_period = 1
      vpc_id                  = module.aws_vpc.vpc_id
      allowed_cidrs           = module.aws_vpc.vpc_cidr
    },
  ]
}

module "rds_replica" {
  source = "github.com/ard-hmd/terraform-aws-rds-replica.git"
  replicate_source_db = "my-db-1"
}
