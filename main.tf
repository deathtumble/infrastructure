terraform {
  backend "s3" {
    bucket = "terraform.backend.urbanfortress.uk"
    region = "eu-west-1"
  }
}
