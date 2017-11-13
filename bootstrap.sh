#!/bin/bash

terraform apply -target=aws_vpc.default
terraform apply -target=aws_internet_gateway.default
terraform apply -target=aws_route_table.main

terraform apply -target=aws_route_table.consul
terraform apply -target=aws_subnet.consul
terraform apply -target=aws_security_group.consul

terraform apply -target=aws_route_table.weblayer
terraform apply -target=aws_subnet.weblayer
terraform apply -target=aws_security_group.weblayer

