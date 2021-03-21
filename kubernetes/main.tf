provider "aws" {
  version = ">= 2.28.1"
  region  = var.region
}

data "aws_eks_cluster" "cluster" {
  name = module.eks-cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks-cluster.cluster_id
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.9"
}

module "eks-cluster" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "start-cluster"
  cluster_version = var.kubernetes_version
  subnets         = var.subnets
  vpc_id          = var.vpc_id

  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]


  worker_groups = [
    {
      instance_type = var.instance_prd
      asg_max_size  = var.asg_max_size_prd
    }
  ]

  workers_group_defaults = {
    root_volume_type              = "gp2"
  }
}