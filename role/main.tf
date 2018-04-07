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
  count                       = "1"
  ami                         = "${var.ami_id}"
  availability_zone           = "${var.availability_zone}"
  tenancy                     = "default"
  ebs_optimized               = "false"
  disable_api_termination     = "false"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
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
 - content: ECS_CLUSTER=${var.role}
   path: /etc/ecs/ecs.config   
   permissions: '0644'
 - content: ${base64encode(file("files/${var.role}_consul.json"))}
   path: /opt/consul/conf/consul.json
   encoding: b64
   permissions: '0644'
 - content: ${base64encode(file("files/${var.role}_goss.yml"))}
   path: /etc/goss/goss.yaml
   encoding: b64
   permissions: '0644'
runcmd:
${var.volume_id == "" ? var.no-mount-cloud-config : var.mount-cloud-config}    
 - service goss start
 - chmod 644 /opt/consul/conf/consul.json
EOF

  tags {
    Name          = "${var.role}"
    Product       = "${var.product}"
    Environment   = "${var.environment}"
    ConsulCluster = "${var.role}"
    Goss          = "true"
  }
}

resource "aws_ecs_cluster" "this" {
  name = "${var.role}"
}

resource "aws_ecs_service" "this" {
  name            = "${var.role}"
  cluster         = "${var.role}"
  task_definition = "${var.task_definition}"
  desired_count   = "${var.desired_count}"
}
