resource "aws_ebs_volume" "monitoring" {
	availability_zone = "${var.availability_zone}"
    size = 22
    tags {
        Name = "monitoring"
    }
}

resource "aws_volume_attachment" "monitoring" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.monitoring.id}"
  instance_id = "${aws_instance.graphite.id}"
  force_detach =false
  depends_on      = ["aws_ebs_volume.monitoring", "aws_instance.graphite"]
}


resource "aws_instance" "graphite" {
	count = "1"
	ami = "${var.ecs_ami_id}"
	availability_zone = "${var.availability_zone}"
	tenancy = "default",
	ebs_optimized = "false",
	disable_api_termination = "false",
    instance_type= "t2.medium"
    key_name = "poc"
    private_ip = "10.0.0.36"
    monitoring = "false",
    vpc_security_group_ids = [
    	"${aws_security_group.graphite.id}",
    	"${aws_security_group.ssh.id}",
    	"${aws_security_group.consul-client.id}"
    ],
    subnet_id = "${aws_subnet.monitoring.id}",
    associate_public_ip_address = "true"
	source_dest_check = "true",
	iam_instance_profile = "ecsinstancerole",
	ipv6_address_count = "0",
    depends_on      = ["aws_security_group.graphite", "aws_security_group.ssh", "aws_security_group.consul-client", "aws_subnet.consul"]
	user_data = <<EOF
#!/bin/bash
mkdir /opt/mount1
mount /dev/xvdh /opt/mount1
echo /dev/xvdh  /opt/mount1 ext4 defaults,nofail 0 2 >> /etc/fstab
ln -s /opt/mount1/grafana/ /var/lib/grafana
ln -s /opt/mount1/grafana_logs/ /var/log/grafana
ln -s /opt/mount1/graphite/ /opt/graphite
ln -s /opt/mount1/nginx_config/ /etc/nginx
ln -s /opt/mount1/statsd_config/ /opt/statsd
ln -s /opt/mount1/graphite_log_files/ /var/log/graphite
cat <<'EOF' >> /etc/ecs/ecs.config
ECS_CLUSTER=graphite
EOF

  tags {
    Name = "graphite-${var.nameTag}"
	Ecosystem = "${var.ecosystem}"
	Environment = "${var.environment}"
	ConsulCluster = "${var.nameTag}"
  }
}

resource "aws_ecs_cluster" "graphite" {
  name = "graphite"
}

resource "aws_ecs_service" "graphite" {
  name            = "graphite"
  cluster         = "graphite"
  task_definition = "graphite:${aws_ecs_task_definition.graphite.revision}"
  depends_on = ["aws_ecs_cluster.graphite", "aws_ecs_task_definition.graphite"]
  desired_count   = 1
}

resource "aws_ecs_task_definition" "graphite" {
  family = "graphite"
  network_mode = "host"
  volume {
			name = "grafana_data"
			host_path = "/var/lib/grafana/"
		}
  volume {
			name = "grafana_plugins"
			host_path = "/var/lib/grafana/plugins"
		}
  volume {
			name = "grafana_logs",
			host_path = "/var/log/grafana"
		}
  volume {
			name = "graphite_config",
			host_path = "/opt/graphite/conf"
		}
  volume {
			name = "graphite_stats_storage",
			host_path = "/opt/graphite/storage"
		}
  volume {
			name = "nginx_config",
			host_path = "/etc/nginx"
		}
  volume {
			name = "statsd_config",
			host_path = "/opt/statsd"
		}
  volume {
			name = "graphite_logrotate_config",
			host_path = "/etc/logrotate.d"
		}
  volume {
			name = "graphite_log_files",
			host_path = "/var/log/graphite"
		}
  
  container_definitions = <<DEFINITION
	[
		{
			"name": "collectd",
			"cpu": 0,
		    "essential": true,
		    "image": "453254632971.dkr.ecr.eu-west-1.amazonaws.com/collectd-write-graphite:0.1.1",
		    "memory": 100,
		    "environment": [
		    	{
		    		"Name": "GRAPHITE_HOST",
		    		"Value": "172.17.0.1"
		    	}, 
		    	{
		    		"Name": "GRAPHITE_PREFIX",
		    		"Value": "${var.ecosystem}.${var.environment}.graphite."
		    	}
		    ]
		},
		{
		    "name": "graphite-statsd",
		    "cpu": 0,
		    "essential": true,
		    "image": "graphiteapp/graphite-statsd:latest",
		    "memory": 400,
		    "portMappings": [
		        {
		          "hostPort": 80,
		          "containerPort": 80,
		          "protocol": "tcp"
		        },
		        {
		          "hostPort": 2003,
		          "containerPort": 2003,
		          "protocol": "tcp"
		        },
		        {
		          "hostPort": 2004,
		          "containerPort": 2004,
		          "protocol": "tcp"
		        },
		        {
		          "hostPort": 2023,
		          "containerPort": 2023,
		          "protocol": "tcp"
		        },
		        {
		          "hostPort": 2024,
		          "containerPort": 2024,
		          "protocol": "tcp"
		        },
		        {
		          "hostPort": 8125,
		          "containerPort": 8125,
		          "protocol": "udp"
		        },
		        {
		          "hostPort": 8126,
		          "containerPort": 8126,
		          "protocol": "udp"
		        }
		    ],
			"mountPoints": [
                {
                  "sourceVolume": "graphite_config",
                  "containerPath": "/opt/graphite/conf",
                  "readOnly": false
                },
                {
                  "sourceVolume": "graphite_stats_storage",
                  "containerPath": "/opt/graphite/storage",
                  "readOnly": false
                },
                {
                  "sourceVolume": "nginx_config",
                  "containerPath": "/etc/nginx",
                  "readOnly": false
                },
                {
                  "sourceVolume": "statsd_config",
                  "containerPath": "/opt/statsd",
                  "readOnly": false
                },
                {
                  "sourceVolume": "graphite_logrotate_config",
                  "containerPath": "/etc/logrotate.d",
                  "readOnly": false
                },
                {
                  "sourceVolume": "graphite_log_files",
                  "containerPath": "/var/log/graphite",
                  "readOnly": false
                }
            ]
        },
		{
		    "name": "grafana",
		    "cpu": 0,
		    "essential": true,
		    "image": "grafana/grafana",
		    "memory": 500,
		    "portMappings": [
		        {
		          "hostPort": 3000,
		          "containerPort": 3000,
		          "protocol": "udp"
		        }
		    ],
		    "mountPoints": [
                {
                  "sourceVolume": "grafana_data",
                  "containerPath": "/var/lib/grafana/",
                  "readOnly": false
                },
                {
                  "sourceVolume": "grafana_plugins",
                  "containerPath": "/var/lib/grafana/plugins",
                  "readOnly": false
                },
                {
                  "sourceVolume": "grafana_logs",
                  "containerPath": "/var/log/grafana",
                  "readOnly": false
                }
            ]
      	}
	]
    DEFINITION
}

resource "aws_lb_cookie_stickiness_policy" "grafana" {
  name                     = "grafana"
  load_balancer            = "${aws_elb.grafana.id}"
  lb_port                  = 80
  cookie_expiration_period = 600
}

resource "aws_elb" "grafana" {
  name            = "grafana"
  security_groups = ["${aws_security_group.grafana.id}"]
  subnets = ["${aws_subnet.monitoring.id}"]
  depends_on = ["aws_security_group.grafana"]
  
  listener {
    instance_port      = 3000
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
  }  

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:3000/api/health"
    interval            = 30
  }
}

resource "aws_route53_record" "grafana" {
	zone_id = "${aws_route53_zone.root.zone_id}"
	name    = "grafana"
    type    = "A"
    depends_on = ["aws_route53_zone.root", "aws_elb.grafana"]

	alias {
		 name = "${aws_elb.grafana.dns_name}"
		 zone_id = "${aws_elb.grafana.zone_id}"
		 evaluate_target_health = "true"
	}
}

resource "aws_elb_attachment" "grafana" {
  count = "1" 
  elb      = "${aws_elb.grafana.id}"
  instance = "${aws_instance.graphite.id}"
}