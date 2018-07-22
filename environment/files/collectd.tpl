        {
            "name": "collectd",
            "cpu": 0,
            "dnsServers": ["127.0.0.1"],
            "essential": false,
            "image": "453254632971.dkr.ecr.eu-west-1.amazonaws.com/collectd-write-graphite:${collectd_docker_tag}",
            "memory": 50,
            "environment": [
                {
                    "Name": "GRAPHITE_HOST",
                    "Value": "graphite.service.consul"
                }, 
                {
                    "Name": "GRAPHITE_PREFIX",
                    "Value": "${graphite_prefix}"
                }
            ]
        }
