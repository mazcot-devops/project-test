provider "aws" {
  region = "ap-southeast-1"
}

module "eks" {
  source            = "terraform-aws-modules/eks/aws"
  cluster_name      = "ml-eks-cluster"
  subnets           = ["subnet-1", "subnet-2", "subnet-3"]  
  vpc_id            = "vpc01234567890abcdef"                          
  cluster_version   = "1.25"
  worker_groups     = {
    eks_nodes = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
    }
  }
}

resource "aws_iam_role" "ml_app_role" {
  name = "ml-app-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks-fargate-pods.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "s3_access_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.ml_app_role.name
}

resource "aws_iam_role_policy_attachment" "sqs_access_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
  role       = aws_iam_role.ml_app_role.name
}
