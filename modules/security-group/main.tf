resource "aws_security_group" "tf-allow-traffic" {
  name        = var.name
  description = "Allow HTTP inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "rule_allow_traffic" {
  security_group_id            = aws_security_group.tf-allow-traffic.id
  cidr_ipv4                    = !startswith(var.sg_rules[count.index].target, "sg") ? var.sg_rules[count.index].target : null
  referenced_security_group_id = startswith(var.sg_rules[count.index].target, "sg") ? var.sg_rules[count.index].target : null
  from_port                    = var.sg_rules[count.index].from_port
  ip_protocol                  = var.sg_rules[count.index].protocol
  to_port                      = var.sg_rules[count.index].to_port
  count                        = length(var.sg_rules)
}