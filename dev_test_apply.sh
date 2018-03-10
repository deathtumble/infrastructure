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


