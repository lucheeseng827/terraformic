resource "aws_instance" "example" {
    ami = "ami=0c255b1519cbfafe1f0"
    instance_type = "t2.micro"
  
    user_data =  <<-EOF
                #!/bin/bash
                echo "hell, world" > index.html
                nohup busybox httpd -f -p 8080 &
                EOF

    tags = {
        Name = "terraform-example"
    }
}
