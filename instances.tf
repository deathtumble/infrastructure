provider "aws" {
  region     = "eu-west-1"
}

data "aws_security_group" "helloworld" {
	name = "helloworld"
}

resource "aws_instance" "helloworld" {
	ami = "ami-95f8d2f3"
	availability_zone = "eu-west-1a"
	tenancy = "default",
	ebs_optimized = "false",
	disable_api_termination = "false",
    instance_type= "t2.micro"
    key_name = "poc"
    monitoring = "false",
    vpc_security_group_ids = ["${data.aws_security_group.helloworld.id}"]
    subnet_id = "subnet-42abac34",
    associate_public_ip_address = "true"
	private_ip = "10.0.0.4"
	source_dest_check = "true",
	iam_instance_profile = "ecsinstancerole",
	ipv6_address_count = "0",
	
	tags {
		Environment = "poc"
	}
}
