
data "aws_caller_identity" "current" {}

locals {
  cluster_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/<LabEksClusterRole>"
  node_role_arn    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/<LabEksNodeRole>"
  admin_role_arn   = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
}

module "eks_cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.31"             

  cluster_name    = var.cluster_name       
  cluster_version = var.cluster_version    
  vpc_id          = var.vpc_id
  subnet_ids      = var.subnet_ids
  tags = var.tags

  cluster_endpoint_public_access = var.cluster_endpoint_public_access  

  create_iam_role = false
  iam_role_arn    = local.cluster_role_arn

  eks_managed_node_groups = {
    default = {
      create_iam_role = false
      iam_role_arn    = local.node_role_arn
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.medium"]
      desired_size   = 2
      min_size       = 2
      max_size       = 5
    }
  }

  aws_auth_roles = [
    {
      rolearn  = local.node_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    },
    {
      rolearn  = local.admin_role_arn      
      username = "lab-admin"
      groups   = ["system:masters"]
    },
  ]

  enable_irsa = false 
  create_aws_auth_configmap = false
  manage_aws_auth_configmap = false
}
