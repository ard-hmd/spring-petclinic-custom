# VPC Configuration
module "aws_vpc" {
  source      = "github.com/ard-hmd/terraform-aws-vpc.git"
  vpc_cidr    = var.vpc_cidr
  environment = var.environment
}

# EKS Cluster Configuration
module "eks_cluster" {
  source              = "github.com/ard-hmd/terraform-aws-eks-cluster.git"
  public_subnets_ids  = module.aws_vpc.public_subnets_ids
  private_subnets_ids = module.aws_vpc.private_subnets_ids
}

# EKS Cluster Node Group Configuration
module "eks_cluster_nodegroup" {
  source              = "github.com/ard-hmd/terraform-aws-eks-nodegroup.git"
  public_subnets_ids  = module.aws_vpc.public_subnets_ids
  private_subnets_ids = module.aws_vpc.private_subnets_ids
  eks_cluster_name    = module.eks_cluster.eks_cluster_name

   # Node Group Details
  node_groups         = [
    {
      name           = "nodegroup-ondemand-1"
      ami_type       = "AL2_x86_64"
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      disk_size      = 20
      scaling_config = {
        desired_size = 2
        max_size     = 3
        min_size     = 1
      }
    }
  ]

  depends_on = [module.eks_cluster]
}

# RDS Instances Configuration
module "rds_instances" {
 source     = "github.com/ard-hmd/terraform-aws-rds.git"
 aws_region = var.aws_region

 # Database Configurations
 database_configurations = [
    # Customers Database Configuration
   {
     identifier              = "customersdb"
     allocated_storage       = 10
     engine_version          = "5.7"
     instance_class          = "db.t3.micro"
     db_name                 = "customersdb"
     db_username             = "admin"
     db_password             = var.customersdb_password
     parameter_group_name    = "default.mysql5.7"
     db_subnet_group_name    = module.aws_vpc.rds_subnet_group_name
     skip_final_snapshot     = true
     publicly_accessible     = false
     backup_retention_period = 1
     vpc_id                  = module.aws_vpc.vpc_id
     allowed_cidrs           = [module.aws_vpc.vpc_cidr]
     multi_az                = true
     sg_name                 = "customers-db-sg"
     sg_description          = "Security Group for customersdb"
   },
   # Vets Database Configuration
   {
     identifier              = "vetsdb"
     allocated_storage       = 10
     engine_version          = "5.7"
     instance_class          = "db.t3.micro"
     db_name                 = "vetsdb"
     db_username             = "admin"
     db_password             = var.vetsdb_password
     parameter_group_name    = "default.mysql5.7"
     db_subnet_group_name    = module.aws_vpc.rds_subnet_group_name
     skip_final_snapshot     = true
     publicly_accessible     = false
     backup_retention_period = 1
     vpc_id                  = module.aws_vpc.vpc_id
     allowed_cidrs           = [module.aws_vpc.vpc_cidr]
     multi_az                = true
     sg_name                 = "vets-db-sg"
     sg_description          = "Security Group for vetsdb"
   },
   # Visits Database Configuration
   {
     identifier              = "visitsdb"
     allocated_storage       = 10
     engine_version          = "5.7"
     instance_class          = "db.t3.micro"
     db_name                 = "visitsdb"
     db_username             = "admin"
     db_password             = var.visitsdb_password
     parameter_group_name    = "default.mysql5.7"
     db_subnet_group_name    = module.aws_vpc.rds_subnet_group_name
     skip_final_snapshot     = true
     publicly_accessible     = false
     backup_retention_period = 1
     vpc_id                  = module.aws_vpc.vpc_id
     allowed_cidrs           = [module.aws_vpc.vpc_cidr]
     multi_az                = true
     sg_name                 = "visits-db-sg"
     sg_description          = "Security Group for visitsdb"
   },
 ]
}

# RDS Replicas Configuration
module "rds_replicas" {
  source = "github.com/ard-hmd/terraform-aws-rds-replica.git"

  # Replica Configurations
  replica_configurations = [
    # Customers Database Replica Configuration
    {
      instance_class          = "db.t3.micro"
      skip_final_snapshot     = true
      backup_retention_period = 0
      replicate_source_db     = "customersdb"
      multi_az                = true
      apply_immediately       = true
      identifier              = "customersdb-replica"
    },
    # Vets Database Replica Configuration
    {
      instance_class          = "db.t3.micro"
      skip_final_snapshot     = true
      backup_retention_period = 0
      replicate_source_db     = "vetsdb"
      multi_az                = true
      apply_immediately       = true
      identifier              = "vetsdb-replica"
    },
    # Visits Database Replica Configuration
    {
      instance_class          = "db.t3.micro"
      skip_final_snapshot     = true
      backup_retention_period = 0
      replicate_source_db     = "visitsdb"
      multi_az                = true
      apply_immediately       = true
      identifier              = "visitsdb-replica"
    },
  ]

  depends_on = [module.rds_instances]
}
