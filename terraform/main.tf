provider "aws" {
  region = "ap-southeast-1"
}

module "eks" {
  source         = "terraform-aws-modules/eks/aws"
  cluster_name   = "ml-eks-cluster"
  subnets        = ["subnet-1", "subnet-2", "subnet-3"]
  vpc_id         = "vpc-01234567890abcdef"
  cluster_version = "1.25"

  worker_groups = {
    eks_nodes = {
      desired_capacity = 2
      max_capacity     = 3
      mln_capacity     = 1
    }
  }
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "s3-access-policy"
  description = "IAM policy for S3 access"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:GetObject", "s3:PutObject"],
        Resource = ["arn:aws:s3:::my-web-assets/*"],
      },
    ],
  })
}

resource "aws_iam_policy" "sqs_access_policy" {
  name        = "sqs-access-policy"
  description = "IAM policy for SQS access"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["sqs:SendMessage", "sqs:ReceiveMessage", "sqs:DeleteMessage"],
        Resource = ["arn:aws:sqs:ap-southeast-1:123456789123:lms-import-data"],
      },
    ],
  })
}

resource "aws_iam_role" "ml_app_role" {
  name             = "ml-app-role"
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
  policy_arn = aws_iam_policy.s3_access_policy.arn
  role       = aws_iam_role.ml_app_role.name
}

resource "aws_iam_role_policy_attachment" "sqs_access_attachment" {
  policy_arn = aws_iam_policy.sqs_access_policy.arn
  role       = aws_iam_role.ml_app_role.name
}
