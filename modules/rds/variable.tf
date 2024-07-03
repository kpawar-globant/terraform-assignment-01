variable "name" {
  type = string
  default = "tf-database"
}

variable "db_class" {
  type = string
  default = "db.t3.micro"
}

variable "db_engine" {
  type = string
  default = "mysql"
}

variable "engine_version" {
  type = string
  default = "8.0"
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "multi_az" {
  type = bool
  default = false
}

variable "publicly_accessible" {
  type = bool
  default = false
}

variable "allocated_storage" {
  type = number
  default = 10
}

variable "security_group_ids" {
    type = list(string)
}

variable "subnet_ids" {
  type = list(string)
}
