variable "name" {
  type    = string
  default = "tf-elb"
}
variable "internal" {
  type    = bool
  default = false
}

variable "load_balancer_type" {
  type    = string
  default = "application"
}

variable "security_group_ids" {
  type = list(string)
}

variable "subnet_ids" {
  type = list(string)
}

variable "enable_deletion_protection" {
  type    = bool
  default = true
}

variable "target_type" {
  type = map(string)
  default = {
    "application" = "alb"
    "network"     = "nlb"
  }
}

variable "target_port" {
  type    = number
  default = 80
}

variable "vpc_id" {
  type = string
}

variable "enable_cross_zone_load_balancing" {
  type    = bool
  default = false
}

variable "certificate_arn" {
  type    = string
  default = ""
}