output "ec2-ip-address" {
  value = module.private-instance[*].private_ip
}

output "jumpserver-address" {
  value = module.jumpserver.public_ip
}

output "database-dns" {
  value = module.rds.dns
}

output "alb-dns" {
  value = module.elb.lb_dns
}