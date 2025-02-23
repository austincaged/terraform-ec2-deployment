output "public_ip" {
  description = "EC2 Public IP"
  value       = aws_instance.web.public_ip
}
