#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source "$SCRIPT_DIR/deploy/helpers/docker_deploy_common.sh"

docker-compose run --rm deployer ./deploy.sh "$@"
