#!/bin/bash

set -e

terraform $@ -state=terraform.tfstate  -var-file=poc_poc_config.vartf

