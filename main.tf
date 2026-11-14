# -----------------------------------------------------------------------------
# Provider Configuration
# -----------------------------------------------------------------------------
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "nginx-ec2-new"
}

# -----------------------------------------------------------------------------
# Data Sources – Ubuntu 20.04 LTS AMI + Default VPC
# -----------------------------------------------------------------------------
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_vpc" "default" {
  default = true
}

# -----------------------------------------------------------------------------
# Security Group – HTTP (80) + SSH (22)
# -----------------------------------------------------------------------------
resource "aws_security_group" "nginx_sg" {
  name        = "terraform-nginx-sg"
  description = "Allow HTTP and SSH traffic"
  vpc_id      = data.aws_vpc.default.id

  # Inbound HTTP
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound – allow all (needed for apt-get)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-nginx-sg"
  }
}

# -----------------------------------------------------------------------------
# EC2 Instance – t2.micro Ubuntu 20.04 with Nginx
# -----------------------------------------------------------------------------
resource "aws_instance" "nginx" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.nginx_sg.id]
  associate_public_ip_address = true

  # Optional key pair (leave empty if you don't want SSH key)
  key_name = var.key_name != "" ? var.key_name : null

  user_data = <<-EOF
              #!/bin/bash
              set -e
              apt-get update -y
              apt-get install -y nginx
              systemctl enable nginx
              systemctl start nginx
              echo "Welcome to the Terraform-managed Nginx Server on Ubuntu" > /var/www/html/index.html
              EOF

  tags = {
    Name = "terraform-nginx-ubuntu"
  }
}