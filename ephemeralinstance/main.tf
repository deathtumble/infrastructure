variable "server_instance_names" {
  default = {
    "0" = "0"
    "1" = "1"
    "2" = "2"
    "3" = "3"
    "4" = "4"
    "5" = "5"
  }
}

resource "aws_instance" "this" {
  count                       = "${var.count}"
  ami                         = "${var.ami_id}"
  availability_zone           = "${var.availability_zone}"
  tenancy                     = "default"
  ebs_optimized               = "false"
  disable_api_termination     = "false"
  instance_type               = "${var.instance_type}"
  key_name                    = "${local.key_name}"
  monitoring                  = "false"
  vpc_security_group_ids      = ["${var.vpc_security_group_ids}"]
  subnet_id                   = "${var.subnet_id}"
  associate_public_ip_address = "true"
  source_dest_check           = "true"
  iam_instance_profile        = "ecsinstancerole"
  ipv6_address_count          = "0"

  user_data = <<EOF
#cloud-config
hostname: ${var.role}    
write_files:
 - content: ECS_CLUSTER=${var.cluster_name}-${local.environment}
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
 - service cadvisor start
 - service node_exporter start
EOF

  tags {
    Name          = "${var.role}-${lookup(var.server_instance_names, count.index)}"
    Product       = "${local.product}"
    Environment   = "${local.environment}"
    ConsulCluster = "${local.product}-${local.environment}"
    Goss          = "true"
  }
}
