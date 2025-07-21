module "eks_cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.31"             

  cluster_name    = var.cluster_name       
  cluster_version = var.cluster_version    
  vpc_id          = data.aws_vpc.default.id
  subnet_ids      = data.aws_subnets.all.ids

  cluster_endpoint_public_access = var.cluster_endpoint_public_access  

  create_iam_role = false
  iam_role_arn    = tolist(data.aws_iam_roles.eks_cluster.arns)[0]

  eks_managed_node_groups = {
    default = {
      create_iam_role = false
      iam_role_arn    = tolist(data.aws_iam_roles.eks_node.arns)[0]
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.medium"]
      desired_size   = 1
      min_size       = 1
      max_size       = 3
    }
  }

  aws_auth_roles = [
    {
      rolearn  = tolist(data.aws_iam_roles.lab_role.arns)[0]
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    },
    {
      rolearn  = tolist(data.aws_iam_roles.lab_role.arns)[0]    
      username = "lab-admin"
      groups   = ["system:masters"]
    },
  ]

  enable_irsa = false 
  create_aws_auth_configmap = false
  manage_aws_auth_configmap = false
}
