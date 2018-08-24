data "aws_subnet" "av" {
    vpc_id            = "${var.vpc_id}"
    availability_zone = "${var.availability_zone}"
}

variable "mount-cloud-config" {
  type = "string"

  default = <<EOF
 - mkdir /opt/mount1
 - sleep 18
 - sudo mount /dev/xvdh /opt/mount1
 - sudo echo /dev/xvdh  /opt/mount1 ext4 defaults,nofail 0 2 >> /etc/fstab
 - sudo mount -a
EOF
}

variable "no-mount-cloud-config" {
  type    = "string"
  default = ""
}

resource "aws_volume_attachment" "this" {
  count        = "${var.volume_id == "" ? 0 : 1}"
  device_name  = "/dev/sdh"
  volume_id    = "${var.volume_id}"
  instance_id  = "${aws_instance.this.id}"
  force_detach = true
}

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
  subnet_id                   = "${data.aws_subnet.av.id}"
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
${var.volume_id == "" ? var.no-mount-cloud-config : var.mount-cloud-config}    
 - service goss start
 - service modd start
 - service consul start
 - service cadvisor start
 - service node_exporter start
EOF

  tags {
    Name          = "${var.role}"
    Product       = "${local.product}"
    Environment   = "${local.environment}"
    ConsulCluster = "${var.role}"
    Goss          = "true"
  }
}


