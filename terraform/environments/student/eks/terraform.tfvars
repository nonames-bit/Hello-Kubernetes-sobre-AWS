region = "us-east-1" 
cluster_name = "tutorial-dann-cluster"
cluster_version = "1.33"

cluster_endpoint_public_access = true
tags = {
  Environment = "student"
  Project     = "MyApp"
  ManagedBy   = "Terraform"
  Stack       = "EKS"
}