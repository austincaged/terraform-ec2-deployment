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

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/Downloads/linux3.pem")
    host        = self.public_ip
    timeout     = "2m"
  }

  user_data = <<-EOF
              #!/bin/bash
              set -ex
              sudo yum update -y
              sudo yum install httpd -y || (echo "Install failed"; exit 1)
              sudo mkdir -p /var/www/html
              sudo systemctl start httpd
              sudo systemctl enable httpd
              EOF

  provisioner "file" {
    source      = "index.html"
    destination = "/home/ec2-user/index.html"
  }

  provisioner "remote-exec" {
    inline = [
      "until [ -d /var/www/html ]; do sleep 2; echo 'Waiting for Apache install...'; done",
      "sudo mv /home/ec2-user/index.html /var/www/html/index.html",
      "sudo chmod 644 /var/www/html/index.html",
      "sudo systemctl restart httpd || echo 'Httpd restart failed'"
    ]
  }

  tags = {
    Name = "auto-web-server"
  }
}

resource "aws_security_group" "web_sg" {
  name        = "web-sg12"
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
