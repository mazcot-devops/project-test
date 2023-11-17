provider "aws" {
  region = "ap-southeast-1"
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "ml-eks-cluster"
  cluster_version = "1.25"

  subnets = {
    private = ["subnet-1", "subnet-2", "subnet-3"]
    public  = ["subnet-4", "subnet-5", "subnet-6"]
  }

  node_groups = {
    eks_nodes = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
    }
  }
}
