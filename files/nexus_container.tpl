        {
            "name": "nexus",
            "cpu": 0,
            "essential": true,
            "image": "sonatype/nexus:oss",
            "memory": 500,
            "portMappings": [
                {
                  "hostPort": 8081,
                  "containerPort": 8081,
                  "protocol": "tcp"
                }
            ],
            "mountPoints": [
                {
                  "sourceVolume": "nexus-data",
                  "containerPath": "/sonatype-work",
                  "readOnly": false
                }
            ]
        }
