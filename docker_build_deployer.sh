#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source "$SCRIPT_DIR/deploy/helpers/docker_deploy_common.sh" dev

docker-compose -f deploy/docker-compose.yml build deployer