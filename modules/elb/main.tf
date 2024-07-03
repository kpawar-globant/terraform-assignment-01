resource "aws_lb" "assignment-lb" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = var.load_balancer_type
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids

  enable_deletion_protection       = var.enable_deletion_protection
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing

}

resource "aws_lb_target_group" "tg-assignment" {
  name        = "tg-${var.name}"
  target_type = lookup(var.target_type, var.load_balancer_type, "alb")
  port        = var.target_port
  protocol    = "TCP"
  vpc_id      = var.vpc_id
}

# HTTPS listener
resource "aws_lb_listener" "listener-https" {
  load_balancer_arn = aws_lb.assignment-lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-assignment.arn
  }
}

# Http listener
resource "aws_lb_listener" "listener-http" {
  load_balancer_arn = aws_lb.assignment-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}