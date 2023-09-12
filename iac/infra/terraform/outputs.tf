output "vpc_id" {
  description = "The ID of the VPC."
  value       = module.aws_vpc.vpc_id
}

output "public_subnets_ids" {
  description = "The IDs of the public subnets."
  value       = module.aws_vpc.public_subnets_ids
}

output "private_subnets_ids" {
  description = "The IDs of the private subnets."
  value       = module.aws_vpc.private_subnets_ids
}

output "rds_subnet_group_name" {
  description = "The name of the RDS subnet group."
  value       = module.aws_vpc.rds_subnet_group_name
}

output "public_route_table_ids" {
  description = "The ID of the public route table."
  value       = module.aws_vpc.public_route_table_ids
}

output "private_route_table_ids" {
  description = "The IDs of the private route tables."
  value       = module.aws_vpc.private_route_table_ids
}

output "internet_gateway_id" {
  description = "The ID of the internet gateway."
  value       = module.aws_vpc.internet_gateway_id
}

output "nat_gateways_ids" {
  description = "The IDs of the NAT gateways."
  value       = module.aws_vpc.nat_gateways_ids
}

output "elastic_ips" {
  description = "The Elastic IPs associated with the NAT gateways."
  value       = module.aws_vpc.elastic_ips
}
