#!/bin/bash

set -e

# terraform $@ -var 'aws_vpc_id=vpc-b0833ed6' -var 'product=poc' -var 'environment=murray' -state=poc-murray.tfstate 

terraform $@ -var 'aws_vpc_id=vpc-3515f853' -var 'product=poc' -var 'environment=poc' -state=terraform.tfstate 
