provider "aws" {
    region = "ap-southeast-1"
    profile = "default"
}

resource "aws_instance" "example" {
    ami = "ami-04dfc6348dc03c931"
    instance_type = "t2.micro"
}


resource "aws_spot_instance_request" "cheap_worker" {
  ami           = "ami-04dfc6348dc03c931"
  spot_price    = "0.6"
  instance_type = "t3.medium"
  spot_type              = "one-time"
  block_duration_minutes = "120"
  wait_for_fulfillment   = "true"
  key_name               = "some_key"
  tags = {
    Name = "CheapWorker"
  }
}


// resource "aws_instance" "cheap_worker" {
//     ami = "ami-08e0a7cfe2d2b21b9"
//     instance_type = "t2.micro"
// }

