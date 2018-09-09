module "vpc" {
  source = "../modules/vpc"
  vpc_cidr = "${var.vpc_cidr}"
  dns_ip = "${var.dns_ip}"
  aws_security_group_alb_id = "${aws_security_group.alb.id}"
  globals          = "${var.globals}"
}

resource "aws_efs_mount_target" "az1" {
    file_system_id = "${local.efs_id}"
    subnet_id      = "${module.vpc.az1_subnet_id}"
    
    security_groups = ["${aws_security_group.efs.id}"]
} 

resource "aws_efs_mount_target" "az2" {
    file_system_id = "${local.efs_id}"
    subnet_id      = "${module.vpc.az2_subnet_id}"

    security_groups = ["${aws_security_group.efs.id}"]
} 

resource "aws_security_group" "efs" {
  name = "efs-${local.product}-${local.environment}"

  vpc_id = "${module.vpc.vpc_id}"
  
  ingress {
    from_port = "2049"
    to_port = "2049"
    security_groups = ["${aws_security_group.os.id}"]
    protocol    = "tcp"
  }
  
}
