module "my_eks_cluster" {
  source = "../../modules/eks"

  cluster_name                   = var.cluster_name
  cluster_version                = var.cluster_version
  cluster_endpoint_public_access = var.cluster_endpoint_public_access
}
