resource "aws_instance" "tf-ec2" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.associate_public_ip_address
  security_groups             = length(var.security_group_ids) > 0 ? var.security_group_ids : [aws_security_group.allow-http[0].id]
  tags = {
    name = var.name
  }
}

# Create security group if it is not passed by user
resource "aws_security_group" "allow-http" {
  name        = "allow-http"
  description = "Allow HTTP inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id
  count = length(var.security_group_ids) > 0 ? 0 : 1
}

# Allow http traffic
resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.allow-http[0].id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
  count = length(var.security_group_ids) > 0 ? 0 : 1
}

