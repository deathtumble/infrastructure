variable "region" {
  type = "string"
  default = "eu-west-1"
}

variable "availability_zone" {
  type = "string"
  default = "eu-west-1c"
}

variable "ecosystem" {
  type = "string"
  default = "poc"
}

variable "environment" {
  type = "string"
  default = "poc"
}

variable "nameTag" {
	type = "string"
	default = "poc-poc"
}

variable "admin_cidr" {
	type = "string"
	default = "81.174.166.51/32"
}

variable "consul_cidr" {
	type = "string"
	default = "10.0.0.0/16"
}

variable "consul_server_instance_ips" {
  default = {
    "0" = "10.0.0.69"
    "1" = "10.0.0.70"
    "2" = "10.0.0.71"
  }
}

