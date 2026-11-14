# Terraform Nginx on Ubuntu EC2

Infrastructure-as-Code project that provisions a simple Nginx web server on Ubuntu 20.04 LTS using Terraform.

## Resources Created

| Resource              | Description                                      |
|-----------------------|--------------------------------------------------|
| `aws_instance.nginx`  | t2.micro Ubuntu 20.04 EC2 instance               |
| `aws_security_group`  | Allows inbound HTTP (80) and SSH (22)            |
| User Data             | Installs Nginx + custom index page               |

- Uses the **default VPC** (no custom VPC / subnet / IGW created)
- AMI is dynamically looked up (latest Ubuntu 20.04 LTS)
- Fully destroyed with `terraform destroy`

## Prerequisites

- AWS CLI configured (`aws configure`) or environment variables
- Terraform ≥ 1.0 installed
- An AWS account with permissions to create EC2 + Security Groups

## How to Run

```bash
# 1. Initialize
terraform init

# 2. Review the plan
terraform plan

# 3. Apply (type 'yes' when prompted)
terraform apply

# 4. Get the public IP
terraform output public_ip