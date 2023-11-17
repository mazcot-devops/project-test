provider "aws" {
  region = "ap-southeast-1"
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "ml-eks-cluster"
  subnets         = ["subnet-1", "subnet-2", "subnet-3"]  
  vpc_id          = "vpc-01234567890abcdef"                          
  cluster_version = "1.25"                                  
  node_groups = {
    eks_nodes = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
    }
  }
}

