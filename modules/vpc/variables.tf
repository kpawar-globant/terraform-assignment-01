variable "cidr_block" {
  type    = string
  default = "10.0.0.0/24"
}

variable "enable_dns_hostnames" {
  type    = bool
  default = false
}

variable "vpc_name" {
  type    = string
  default = "tf-main"
}

variable "private_subnet_cidr" {
  type    = list(string)
  default = ["10.1.0.0/27", "10.3.0.0/27"]
}

variable "public_subnet_cidr" {
  type    = list(string)
  default = ["10.2.0.0/27"]
}

variable "az_list" {
  type    = list(string)
  default = ["ap-south-1a", "ap-south-1b"]
}

variable "nat_gateway_per_az" {
  type    = bool
  default = false
}

variable "nat_gateway_enabled" {
  type    = bool
  default = true
}

variable "single_nat_gateway" {
  type    = bool
  default = true
}

variable "multiple_public_route_table" {
  default = false
  type    = bool
}