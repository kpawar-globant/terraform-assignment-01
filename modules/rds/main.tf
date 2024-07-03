resource "aws_db_instance" "tf-database" {
  allocated_storage      = var.allocated_storage
  db_name                = var.name
  engine                 = var.db_engine
  engine_version         = var.engine_version
  instance_class         = var.db_class
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.private-sub-group.name
  multi_az               = var.multi_az
  publicly_accessible    = var.publicly_accessible
  vpc_security_group_ids = var.security_group_ids
}

# Placing database in 3rd and 4th private subnet as no EC2 instance is there
resource "aws_db_subnet_group" "private-sub-group" {
  name       = "tf-${var.name}-sub-group"
  subnet_ids = var.subnet_ids
}