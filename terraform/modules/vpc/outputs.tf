output "vpc_id" {
  description = "El ID de la VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs de las subredes públicas."
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "IDs de las subredes privadas."
  value       = module.vpc.private_subnets
}