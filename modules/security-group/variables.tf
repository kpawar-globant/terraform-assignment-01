variable "name" {
  type    = string
  default = "allow-traffic-sg"
}

variable "vpc_id" {
  type = string
}

variable "sg_rules" {
  type = list(object({
    to_port   = number
    from_port = number
    protocol  = string
    target    = string
  }))
}