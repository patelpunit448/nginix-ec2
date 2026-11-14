output "public_ip" {
  description = "Public IP address of the Nginx EC2 instance"
  value       = aws_instance.nginx.public_ip
}

output "public_dns" {
  description = "Public DNS name of the instance"
  value       = aws_instance.nginx.public_dns
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.nginx.id
}