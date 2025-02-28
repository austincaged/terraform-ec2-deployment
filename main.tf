# main.tf
provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "web" {
  ami           = "ami-0003ba2a7a89ddb0c" # Amazon Linux 2
  instance_type = "t2.micro"
  key_name      = "linux3" 
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  depends_on    = [aws_security_group.web_sg]


  user_data = <<-EOF
              #!/bin/bash
              set -ex
              sudo yum update -y
              sudo yum install httpd -y || (echo "Install failed"; exit 1)
              sudo mkdir -p /var/www/html
              sudo systemctl start httpd
              sudo systemctl enable httpd
              EOF


  tags = {
    Name = "auto-web-server"
  }
}

resource "aws_security_group" "web_sg" {
  name        = "web-sg20"
  description = "Allow HTTP and SSH traffic"
  vpc_id      = "vpc-04447e0873377df96"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
