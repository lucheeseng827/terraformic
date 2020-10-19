
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.6.0"
    }
  }

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "derp"

    workspaces {
      name = "eks-poc"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

data "aws_eks_cluster" "cluster" {
  name = module.my-cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.my-cluster.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.9"
}

module "my-cluster" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "my-eks"
  cluster_version = "1.17"
  subnets = [aws_subnet.public-a.id, aws_subnet.private-a.id]
  vpc_id          = aws_vpc.id
  manage_aws_auth = true
  map_users       = var.aws_user

  worker_groups_launch_template = [
    {
      name                    = "application-nodegroup"
      override_instance_types = ["m5.large"]
      spot_instance_pools     = 1
      asg_max_size            = 1
      asg_desired_capacity    = 1
      kubelet_extra_args      = "--node-labels=node.kubernetes.io/lifecycle=spot"
      public_ip               = false
    },
  ]
}

#cloudwatch group
resource "aws_cloudwatch_log_group" "eks_log_group" {
  name              = "/aws/eks/poc-k8/cluster"
  retention_in_days = 7
}


#install helm 
