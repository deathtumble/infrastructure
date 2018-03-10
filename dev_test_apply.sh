#!/bin/bash

set -e

terraform $@ \
-state=terraform.tfstate \
-var 'aws_vpc_id=vpc-3515f853' \
-var 'product=poc' \
-var 'environment=poc' \
-var 'nexus_volume_id=vol-0c80683f4a8142d69' \
-var 'monitoring_volume_id=vol-0a53b71d35611d427' \
-var 'concourse_volume_id=vol-0cc66dcb2a5b637d2' \
-var 'nameTag=poc-poc' \
-var 'root_domain_name=urbanfortress.uk' \
-var 'aws_route53_zone_id=ZHWSM6HESLWEO' \
-var 'key_name=poc' \
-var 'admin_cidr=81.174.166.51/32' 
