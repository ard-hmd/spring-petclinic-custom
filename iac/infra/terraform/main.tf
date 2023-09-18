module "aws_vpc" {
    source          = "github.com/ard-hmd/terraform-aws-vpc.git"
    vpc_cidr        = var.vpc_cidr
    environment     = var.environment
}

module "eks_cluster" {
  source          = "github.com/ard-hmd/terraform-aws-eks-cluster.git"
  public_subnets_ids = module.aws_vpc.public_subnets_ids
  private_subnets_ids = module.aws_vpc.private_subnets_ids
}

module "eks_cluster_nodegroup" {
    source          = "github.com/ard-hmd/terraform-aws-eks-nodegroup.git"
    public_subnets_ids = module.aws_vpc.public_subnets_ids
    private_subnets_ids = module.aws_vpc.private_subnets_ids
    eks_cluster_name = module.eks_cluster.eks_cluster_name
    node_groups     = [
      {
        name = "nodegroup-ondemand"
        ami_type       = "AL2_x86_64"
        instance_types = ["t3.xlarge"]
        capacity_type  = "ON_DEMAND"
        disk_size      = 20
      },
    ]
}


# module "rds_instances" {
#   source       = "github.com/ard-hmd/terraform-aws-rds.git"
#   aws_region   = var.aws_region
#   database_configurations = [
#     {
#       identifier              = "my-db-1"
#       allocated_storage       = 10
#       engine_version          = "5.7"
#       instance_class          = "db.t3.micro"
#       db_name                 = "mydatabase1"
#       db_username             = "admin1"
#       db_password             = "password1"
#       parameter_group_name    = "default.mysql5.7"
#       db_subnet_group_name    = module.aws_vpc.rds_subnet_group_name
#       skip_final_snapshot     = true
#       publicly_accessible     = false
#       backup_retention_period = 1
#       vpc_id                  = module.aws_vpc.vpc_id
#       allowed_cidrs           = module.aws_vpc.vpc_cidr
#       multi_az                = true
#     },
#     {
#       identifier              = "my-db-2"
#       allocated_storage       = 10
#       engine_version          = "5.7"
#       instance_class          = "db.t3.micro"
#       db_name                 = "mydatabase2"
#       db_username             = "admin1"
#       db_password             = "password1"
#       parameter_group_name    = "default.mysql5.7"
#       db_subnet_group_name    = module.aws_vpc.rds_subnet_group_name
#       skip_final_snapshot     = true
#       publicly_accessible     = false
#       backup_retention_period = 1
#       vpc_id                  = module.aws_vpc.vpc_id
#       allowed_cidrs           = module.aws_vpc.vpc_cidr
#       multi_az                = true
#     },
#   ]
# }

# module "rds_replicas" {
#   source       = "github.com/ard-hmd/terraform-aws-rds-replica.git"
#   replica_configurations = [
#     {
#       instance_class          = "db.t3.micro"
#       skip_final_snapshot     = true
#       backup_retention_period = 0
#       replicate_source_db     = "my-db-1"
#       multi_az                = true
#       apply_immediately       = true
#       identifier              = "my-db-1-replica"
#     },
#     {
#       instance_class          = "db.t3.micro"
#       skip_final_snapshot     = true
#       backup_retention_period = 0
#       replicate_source_db     = "my-db-2"
#       multi_az                = true
#       apply_immediately       = true
#       identifier              = "my-db-2-replica"
#     },
#   ]

#   depends_on = [module.rds_instances]
# }