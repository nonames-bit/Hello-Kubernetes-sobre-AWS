# Invoca el módulo VPC de Terraform Registry
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0" 

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs              = var.azs
  private_subnets  = var.private_subnets
  public_subnets   = var.public_subnets
  # isolated_subnets = [] # Opcional, para subredes aisladas sin salida a internet

  enable_nat_gateway     = true
  single_nat_gateway     = true # Opcional: un solo NAT Gateway por VPC
  enable_dns_hostnames   = true
  enable_dns_support     = true

  tags = var.tags
}