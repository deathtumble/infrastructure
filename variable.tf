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
