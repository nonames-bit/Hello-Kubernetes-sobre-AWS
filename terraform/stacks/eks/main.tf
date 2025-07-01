data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "<bucket_name>" 
    key    = "workspaces/${terraform.workspace}/networking/terraform.tfstate"
    region = var.region
  }
}

module "my_eks_cluster" {
  source = "../../modules/eks"

  cluster_name                   = var.cluster_name
  cluster_version                = var.cluster_version
  tags                           = var.tags
  cluster_endpoint_public_access = var.cluster_endpoint_public_access

  vpc_id     = data.terraform_remote_state.networking.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.networking.outputs.private_subnet_ids 
}
