resource "aws_volume_attachment" "this" {
  device_name = "/dev/sdh"
  volume_id   = "${var.volume_id}"
  instance_id = "${aws_instance.this.id}"
  force_detach = true
}

resource "aws_instance" "this" {
    count = "1"
    ami = "${var.ami_id}"
    availability_zone = "${var.availability_zone}"
    tenancy = "default",
    ebs_optimized = "false",
    disable_api_termination = "false",
    instance_type= "${var.instance_type}"
    key_name = "poc"
    private_ip = "${var.private_ip}"
    monitoring = "false",
    vpc_security_group_ids = ["${var.vpc_security_group_ids}"]
    subnet_id = "${var.aws_subnet_id}",
    associate_public_ip_address = "true"
    source_dest_check = "true",
    iam_instance_profile = "ecsinstancerole",
    ipv6_address_count = "0",
    user_data = <<EOF
#!/bin/bash
mkdir /opt/mount1
echo /dev/xvdh  /opt/mount1 ext4 defaults,nofail 0 2 >> /etc/fstab
sleep 10
mount /dev/xvdh /opt/mount1
cat <<'EOF' >> /etc/ecs/ecs.config
ECS_CLUSTER=${var.role}
EOF

  tags {
    Name = "${var.role}"
    Ecosystem = "${var.ecosystem}"
    Environment = "${var.environment}"
  }
}

