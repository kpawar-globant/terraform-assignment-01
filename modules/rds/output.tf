output "dns" {
  value = aws_db_instance.tf-database.domain_fqdn
}

output "arn" {
  value = aws_db_instance.tf-database.arn
}