#!/bin/bash
export CLOUDREACTOR_PROCESS_VERSION_SIGNATURE=`git rev-parse HEAD`

if [ -z "$1" ]
  then
    echo "Usage: $0 <deployment>"
    exit 1
  else
    export DEPLOYMENT_ENVIRONMENT=$1
fi

VAR_FILENAME="deploy/vars/$DEPLOYMENT_ENVIRONMENT.yml"

echo "VAR_FILENAME = $VAR_FILENAME"

if [[ ! -f $VAR_FILENAME ]]
  then
    echo "$VAR_FILENAME does not exist, please copy deploy/vars/example.yml to $VAR_FILENAME and fill in your secrets."
    exit 1
fi

PER_ENV_FILE="deploy/docker_deploy.$DEPLOYMENT_ENVIRONMENT.env"

if [[ ! -f deploy/docker_deploy.env ]] && [[ ! -f $PER_ENV_FILE ]]
then
  echo "WARNING: neither docker_deploy.env nor $PER_ENV_FILE we found, creating empty ones."
fi

touch -a deploy/docker_deploy.env
touch -a $PER_ENV_FILE

echo "DEPLOYMENT_ENVIRONMENT = $DEPLOYMENT_ENVIRONMENT"
echo "CLOUDREACTOR_PROCESS_VERSION_SIGNATURE = $CLOUDREACTOR_PROCESS_VERSION_SIGNATURE"
