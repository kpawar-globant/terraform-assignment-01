variable "instance_type" {
  type = string
  default = "t3.micro"
}

variable "ami" {
  type = string
}

variable "name" {
    type = string
    default = "tf-ec2-instance"
}

variable "subnet_id" {
  type = string
}

variable "associate_public_ip_address" {
  type = bool
  default = false
}

variable "security_group_ids" {
  type = list(string)
  default = []
}

variable "vpc_id" {
  type = string
}