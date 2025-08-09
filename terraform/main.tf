terraform {
  required_version = ">= 1.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }

  backend "s3" {
    bucket         = var.tfstate_bucket
    key            = "${var.cluster_name}/terraform.tfstate"
    region         = var.region
    dynamodb_table = var.tfstate_lock_table
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
}

# ECR repo
resource "aws_ecr_repository" "app" {
  name = var.ecr_repo_name
  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "AES256"
  }
}

# EKS cluster using terraform-aws-modules/eks
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.0.0" # pick a stable version; you may update later

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  subnets         = null
  vpc_id          = null

  manage_aws_auth = true

  # Let module create a VPC for you (simple path)
  cluster_create_timeout = "30m"

  node_groups = {
    default = {
      desired_capacity = var.node_count
      max_capacity     = var.node_max
      min_capacity     = var.node_min
      instance_type    = var.node_type
    }
  }

  tags = {
    Project = "eks-web-game"
  }
}

output "ecr_uri" {
  value = aws_ecr_repository.app.repository_url
}

output "cluster_name" {
  value = module.eks.cluster_id
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "kubeconfig_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}
