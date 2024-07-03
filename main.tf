provider "aws" {
  region = "ap-south-1"
  default_tags {
    tags = {
      owner       = "Kiran Pawar",
      environment = "sandbox"
      purpose     = "assignment"
      createdBy   = "Terraform"
    }
  }
}

# Create VPC
module "assignment-vpc" {
  source                      = "./modules/vpc"
  cidr_block                  = "10.0.0.0/24"
  enable_dns_hostnames        = true
  vpc_name                    = "assignment-vpc"
  public_subnet_cidr          = var.public_subnet_cidr
  private_subnet_cidr         = var.private_subnet_cidr
  single_nat_gateway          = true
  az_list                     = ["ap-south-1a", "ap-south-1b"]
  nat_gateway_per_az          = false
  nat_gateway_enabled         = true
  multiple_public_route_table = false
}

# Fetching latest Amazon Linux image
data "aws_ami" "AmLinux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*"]
  }
}

# security group for jumpserver
module "security_group" {
  source   = "./modules/security-group"
  vpc_id   = module.assignment-vpc.vpc_id
  sg_rules = [{ to_port = 80, from_port = 80, protocol = "tcp", target = "0.0.0.0/0" }]
}

# EC2 instance for jumpserver 
module "jumpserver" {
  source                      = "./modules/ec2"
  ami                         = data.aws_ami.AmLinux.id
  instance_type               = "t3.micro"
  name                        = "jumpserver"
  subnet_id                   = coalesce(var.public_subnet_cidr...)
  vpc_id                      = module.assignment-vpc.vpc_id
  associate_public_ip_address = true
  security_group_ids          = [module.security_group.security_group_id]
}

# Create 2 private instances
module "private-instance" {
  source             = "./modules/ec2"
  ami                = data.aws_ami.AmLinux.id
  instance_type      = "t3.micro"
  name               = "private-instance-${count.index}"
  subnet_id          = element(var.private_subnet_cidr, count.index)
  vpc_id             = module.assignment-vpc.vpc_id
  security_group_ids = [module.security_group.security_group_id]
  count              = 2
}

# security group for database (Allow internal traffic)
module "db-security_group" {
  source   = "./modules/security-group"
  vpc_id   = module.assignment-vpc.vpc_id
  sg_rules = [{ to_port = 3306, from_port = 3306, protocol = "tcp", target = var.vpc_cidr }]
}

# Create RDS (mysql)
module "rds" {
  source             = "./modules/rds"
  name               = "tf-mysql-db"
  db_username        = var.db_username
  db_password        = var.db_password
  subnet_ids         = var.private_subnet_cidr
  security_group_ids = [module.db-security_group.security_group_id]
}

# security group for load balancer (Allow internal traffic)
module "lb_security_group" {
  source   = "./modules/security-group"
  vpc_id   = module.assignment-vpc.vpc_id
  sg_rules = [{ to_port = 80, from_port = 80, protocol = "tcp", target = "0.0.0.0/0" }, { to_port = 443, from_port = 443, protocol = "tcp", target = "0.0.0.0/0" }]
}

# Create Application load balancer
module "elb" {
  source             = "./modules/elb"
  name               = "tf-assignment-alb"
  security_group_ids = [module.lb_security_group.security_group_id]
  subnet_ids         = var.public_subnet_cidr
  vpc_id             = module.assignment-vpc.vpc_id
  certificate_arn    = ""
}

locals {
  instance_ids = concat(module.private-instance[*].instance_id, module.jumpserver[*].instance_id)
}

# Load balancer attachent 
resource "aws_lb_target_group_attachment" "tg-attachment" {
  target_group_arn = module.elb.tg_arn
  target_id        = element(local.instance_ids, count.index)
  port             = 80
  count            = length(concat(var.public_subnet_cidr, var.private_subnet_cidr))
}