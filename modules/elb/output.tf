output "tg_arn" {
  value = aws_lb_target_group.tg-assignment.arn
}

output "lb_dns" {
  value = aws_lb.assignment-lb.dns_name
}