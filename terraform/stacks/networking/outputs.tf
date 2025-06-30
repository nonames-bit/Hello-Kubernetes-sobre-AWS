output "vpc_id" {
  description = "El ID de la VPC creada."
  value       = module.project_vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs de las subredes públicas de la VPC."
  value       = module.project_vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs de las subredes privadas de la VPC."
  value       = module.project_vpc.private_subnet_ids
}