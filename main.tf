# main.tf
provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "web" {
  ami           = "ami-0003ba2a7a89ddb0c" # Ubuntu 22.04 LTS
  instance_type = "t2.micro"
  key_name      = "linux2"  # Replace with your AWS key pair name
  
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "linux-server"
  }
}

resource "aws_security_group" "web_sg" {
  name = "web-sg"

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
