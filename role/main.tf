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
 - content: ECS_CLUSTER=${var.role}-${var.environment}
   path: /etc/ecs/ecs.config   
   permissions: '0644'
runcmd:
${var.volume_id == "" ? var.no-mount-cloud-config : var.mount-cloud-config}    
 - service goss start
 - service modd start
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
  name = "${var.role}-${var.environment}"
}

resource "aws_ecs_service" "this" {
  name            = "${var.role}-${var.environment}"
  cluster         = "${var.role}-${var.environment}"
  task_definition = "${var.task_definition}"
  desired_count   = "${var.task_status == "down" ? 0 : var.desired_task_count}"
}
