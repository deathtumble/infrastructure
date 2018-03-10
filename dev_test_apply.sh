#!/bin/bash

set -e

terraform apply -var 'ecs_ami_id=ami-eac98593' -var 'aws_vpc_id=vpc-3515f853'   

