# Create a new instance of the latest Ubuntu 20.04 on an
# t3.micro node with an AWS Tag naming it Terraform-1 and Server-n"
provider "aws" {
  region = "ap-southeast-1"
}

variable "instance_count" {
  default = "2"
}

variable "instance_tags" {
  type = list
  default = ["Terraform-1", "Terraform-2"]
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  count         = var.instance_count 
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  user_data = "#!/bin/bash\nsudo apt-get update"

  tags = {
    Name  = "Server-${count.index}"
    type  = "${var.instance_tags[0]}"
  }

  }
  