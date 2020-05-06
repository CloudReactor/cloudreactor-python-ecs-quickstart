#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source "$SCRIPT_DIR/deploy/helpers/docker_deploy_common.sh"

docker-compose -f deploy/docker-compose.yml run --rm deployer ./deploy.sh "$@"
