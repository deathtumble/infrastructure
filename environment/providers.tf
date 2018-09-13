provider "aws" {
  version = "~> 1.31.0"

  region = "${var.region}"
}

provider "template" {
  version = "~> 0.1"
}

provider "null" {
  version = "~> 0.1"
}

