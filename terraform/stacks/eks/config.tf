provider "aws" {
  region = var.region
  default_tags {
    tags = {
      "terraform" : true,
      "author" : terraform.workspace
    }
  }
}

terraform {
  required_version = "~> 1.12.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5"
    }
  }
  backend "s3" {
    bucket               = var.state_bucket
    key                  = var.state_key
    region               = var.region
    workspace_key_prefix = "workspaces"
    encrypt              = true
  }
}