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
  region = "ap-souteast-1"
}


resource "aws_vpc" "mancube-eks" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "mancube-eks"
  }
}

data "aws_vpc" "selected" {
  id = aws_vpc.mancube-eks.id
}

resource "aws_subnet" "public-a" {
  vpc_id                  = aws_vpc.mancube-eks.id
  cidr_block              = "10.0.0.0/20"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true
  tags = {
    Name                                = "public-a",
    "kubernetes.io/cluster/mancube-eks" = "shared"
  }
}

data "aws_subnet" "public-a" {
  id = aws_subnet.public-a.id
}

resource "aws_subnet" "public-b" {
  vpc_id                  = aws_vpc.mancube-eks.id
  cidr_block              = "10.0.16.0/20"
  availability_zone       = "ap-southeast-1b"
  map_public_ip_on_launch = true
  tags = {
    Name                                = "public-b",
    "kubernetes.io/cluster/mancube-eks" = "shared"
  }
}

data "aws_subnet" "public-b" {
  id = aws_subnet.public-b.id
}

resource "aws_subnet" "public-c" {
  vpc_id                  = aws_vpc.mancube-eks.id
  cidr_block              = "10.0.32.0/20"
  availability_zone       = "ap-southeast-1c"
  map_public_ip_on_launch = true
  tags = {
    Name                                = "public-c",
    "kubernetes.io/cluster/mancube-eks" = "shared"
  }
}

data "aws_subnet" "public-c" {
  id = aws_subnet.public-c.id
}

resource "aws_subnet" "private-a" {
  vpc_id            = aws_vpc.mancube-eks.id
  cidr_block        = "10.0.48.0/20"
  availability_zone = "ap-southeast-1a"
  tags = {
    Name                                = "private-a",
    "kubernetes.io/cluster/mancube-eks" = "shared"
  }
}

data "aws_subnet" "private-a" {
  id = aws_subnet.private-a.id
}

resource "aws_subnet" "private-b" {
  vpc_id            = aws_vpc.mancube-eks.id
  cidr_block        = "10.0.64.0/20"
  availability_zone = "ap-southeast-1b"
  tags = {
    Name                                = "private-b",
    "kubernetes.io/cluster/mancube-eks" = "shared"
  }
}

data "aws_subnet" "private-b" {
  id = aws_subnet.private-b.id
}

resource "aws_subnet" "private-c" {
  vpc_id            = aws_vpc.mancube-eks.id
  cidr_block        = "10.0.80.0/20"
  availability_zone = "ap-southeast-1c"
  tags = {
    Name                                = "private-c",
    "kubernetes.io/cluster/mancube-eks" = "shared"
  }
}

data "aws_subnet" "private-c" {
  id = aws_subnet.private-c.id
}

#assignment of routetable
resource "aws_default_route_table" "route-public" {
  default_route_table_id = aws_vpc.mancube-eks.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "rtb-main"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "route-private-a" {
  vpc_id = aws_vpc.mancube-eks.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw-a.id
  }

  tags = {
    Name = "rtb-private-a"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "route-private-b" {
  vpc_id = aws_vpc.mancube-eks.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw-b.id
  }


  tags = {
    Name = "rtb-private-b"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "route-private-c" {
  vpc_id = aws_vpc.mancube-eks.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw-c.id
  }


  tags = {
    Name = "rtb-private-c"
  }

  depends_on = [aws_nat_gateway.gw-c]
}

#adding nat gateway
#eip
resource "aws_eip" "eipa" {
  vpc = true
}

resource "aws_eip" "eipb" {
  vpc = true
}

resource "aws_eip" "eipc" {
  vpc = true
}

resource "aws_nat_gateway" "gw-a" {
  allocation_id = aws_eip.eipa.id
  subnet_id     = aws_subnet.public-a.id

  depends_on = [aws_eip.eipa]

  tags = {
    Name = "gw-nat-a"
  }
}

resource "aws_nat_gateway" "gw-b" {
  allocation_id = aws_eip.eipb.id
  subnet_id     = aws_subnet.public-b.id

  depends_on = [aws_eip.eipa]

  tags = {
    Name = "gw-nat-b"
  }
}

resource "aws_nat_gateway" "gw-c" {
  allocation_id = aws_eip.eipc.id
  subnet_id     = aws_subnet.public-c.id

  depends_on = [aws_eip.eipa]

  tags = {
    Name = "gw-nat-c"
  }
}

output "nat_gateway_ip_a" {
  value = aws_eip.eipa.public_ip
}

output "nat_gateway_ip_b" {
  value = aws_eip.eipb.public_ip
}

output "nat_gateway_ip_c" {
  value = aws_eip.eipc.public_ip
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.mancube-eks.id

  depends_on = [aws_vpc.mancube-eks]

  tags = {
    Name = "igw-mancube"
  }
}

resource "aws_route_table_association" "public_subnet-a" {
  subnet_id      = aws_subnet.public-a.id
  route_table_id = aws_default_route_table.route-public.id
}

resource "aws_route_table_association" "public_subnet-b" {
  subnet_id      = aws_subnet.public-b.id
  route_table_id = aws_default_route_table.route-public.id
}

resource "aws_route_table_association" "public_subnet-c" {
  subnet_id      = aws_subnet.public-c.id
  route_table_id = aws_default_route_table.route-public.id
}

resource "aws_route_table_association" "private_subnet-a" {
  subnet_id      = aws_subnet.private-a.id
  route_table_id = aws_route_table.route-private-a.id
}

resource "aws_route_table_association" "private_subnet-b" {
  subnet_id      = aws_subnet.private-b.id
  route_table_id = aws_route_table.route-private-b.id
}

resource "aws_route_table_association" "private_subnet-c" {
  subnet_id      = aws_subnet.private-c.id
  route_table_id = aws_route_table.route-private-c.id
}
