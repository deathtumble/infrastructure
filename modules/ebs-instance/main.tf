variable "server_instance_names" {
  default = {
    "0" = "-0"
    "1" = "-1"
    "2" = "-2"
    "3" = "-3"
    "4" = "-4"
    "5" = "-5"
  }
}

resource "aws_instance" "this" {
  count                       = var.instance_count
  ami                         = var.ami_id
  availability_zone           = var.availability_zone
  tenancy                     = "default"
  ebs_optimized               = "false"
  disable_api_termination     = "false"
  instance_type               = var.instance_type
  key_name                    = var.context.environment.key_name
  monitoring                  = "false"
  vpc_security_group_ids      = var.vpc_security_group_ids
  subnet_id                   = var.subnet_id
  associate_public_ip_address = "true"
  source_dest_check           = "true"
  iam_instance_profile        = "ecsinstancerole"
  ipv6_address_count          = "0"

  user_data = <<EOF
#cloud-config
hostname: ${var.cluster_name}    
write_files:
 - content: ECS_CLUSTER=${var.cluster_name}-${var.context.environment.name}
   path: /etc/ecs/ecs.config   
   permissions: '0644'
 - content: |
      RECURSOR=10.0.0.2
      REGION=${var.region}
      CONSUL_CLUSTER=${var.context.product.name}-${var.context.environment.name}
   path: /etc/consul/setenv.sh   
   permissions: '0644'
runcmd:
 - mkdir /opt/mount1
 - sleep 18
 - sudo echo ${var.efs_id}:/  /opt/mount1 efs defaults,_netdev 0 0 >> /etc/fstab
 - sudo mount -a
 - service goss start
 - service modd start
 - service consul start
 - service cadvisor start
 - service node_exporter start
 - sudo /usr/bin/monit
EOF


  tags = {
    Name = "${var.cluster_name}${var.instance_count == 1 ? "" : var.server_instance_names[count.index]}"
    Product = var.context.product.name
    Environment = var.context.environment.name
    ConsulCluster = "${var.context.product.name}-${var.context.environment.name}"
    Goss = "true"
    ElasticSearchCluster = var.context.environment.name
  }
}

