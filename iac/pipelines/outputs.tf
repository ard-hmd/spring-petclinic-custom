output "id_customers" { value = module.codebuild_customers.id }
output "id_vets" { value = module.codebuild_vets.id }
output "id_visits" { value = module.codebuild_visits.id }
output "id_api_gateway" { value = module.codebuild_api_gateway.id }
output "build_role_arn" { value = module.roles.build_role_arn }