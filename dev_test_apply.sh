#!/bin/bash

set -e

terraform $@ -state=terraform.tfstate  -var-file=dev_config.vartf