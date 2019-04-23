provider "aws" {
  version = "~> 2.7"

  region = "${var.region}"
}

provider "template" {
  version = "~> 2.1"
}

provider "null" {
  version = "~> 2.1"
}

