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



provider "helm" {
  kubernetes {
    host = "https://104.196.242.174"
    # username               = "ClusterMaster"
    # password               = "MindTheGap"
    client_certificate     = file("~/.kube/client-cert.pem")
    client_key             = file("~/.kube/client-key.pem")
    cluster_ca_certificate = file("~/.kube/cluster-ca-cert.pem")
  }
}
