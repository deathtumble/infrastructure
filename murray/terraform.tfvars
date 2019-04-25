
context = {
  aws_account_id = "453254632971"
  region = {
    name   = "eu-west-1"
    efs_id = "fs-95ebc95c"
  }
  environment = {
    name     = "murray"
    key_name = "poc"
  }
  product = {
    name             = "poc"
    root_domain_name = "urbanfortress.uk"
  }
  vpcs = {
    "primary" = {
      name   = "primary"
      cidr   = "10.0.0.0/16"
      dns_ip = "10.0.0.2"
      azs = {
        "1st" = {
          name   = "eu-west-1a"
          subnet = "10.0.0.0/25"
        },
        "2nd" = {
          name   = "eu-west-1b"
          subnet = "10.0.0.128/25"
        }
      }
    }
  }
}

services = {
  elasticsearch = {
    name          = "elasticsearch"
    docker_tag    = "e7499ed"
    task_status   = "up"
    desired_count = "1"
  },
}


