#!/bin/bash

# Run this script to debug build problems. It will take you to a
# bash shell in the deployer container so you can inspect the files
# that ansible writes. The working directory is mounted in /work and
# and you can re-run ansible by typing "./deploy.sh <deployment>" in the
# working directory, where <deployment> is the deployment target.

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source "$SCRIPT_DIR/deploy/helpers/docker_deploy_common.sh"

docker-compose -f deploy/docker-compose.yml run --rm deployer bash
