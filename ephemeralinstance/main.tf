
resource "aws_instance" "this" {
  count                       = "${var.desired_instance_count}"
  ami                         = "${var.ami_id}"
  availability_zone           = "${var.availability_zone}"
  tenancy                     = "default"
  ebs_optimized               = "false"
  disable_api_termination     = "false"
  instance_type               = "${var.instance_type}"
  key_name                    = "${local.key_name}"
  monitoring                  = "false"
  vpc_security_group_ids      = ["${var.vpc_security_group_ids}"]
  subnet_id                   = "${var.aws_subnet_id}"
  associate_public_ip_address = "true"
  source_dest_check           = "true"
  iam_instance_profile        = "ecsinstancerole"
  ipv6_address_count          = "0"

  user_data = <<EOF
#cloud-config
hostname: ${var.role}    
write_files:
 - content: ECS_CLUSTER=${var.role}-${local.environment}
   path: /etc/ecs/ecs.config   
   permissions: '0644'
 - content: |
      RECURSOR=10.0.0.2
      REGION=${var.region}
      CONSUL_CLUSTER=${local.product}-${local.environment}
   path: /etc/consul/setenv.sh   
   permissions: '0644'
runcmd:
 - service goss start
 - service modd start
 - service consul start
EOF

  tags {
    Name          = "${var.role}"
    Product       = "${local.product}"
    Environment   = "${local.environment}"
    ConsulCluster = "${var.role}"
    Goss          = "true"
  }
}

