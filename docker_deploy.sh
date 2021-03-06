#!/bin/bash
set -e

if [ -z "$1" ]
  then
    echo "Usage: $0 <deployment>"
    exit 1
  else
    export DEPLOYMENT_ENVIRONMENT=$1
fi

VAR_FILENAME="deploy_config/vars/$DEPLOYMENT_ENVIRONMENT.yml"

echo "VAR_FILENAME = $VAR_FILENAME"

if [[ ! -f $VAR_FILENAME ]]
  then
    echo "$VAR_FILENAME does not exist, please copy deploy_config/vars/example.yml to $VAR_FILENAME and fill in your secrets."
    exit 1
fi

PER_ENV_FILE="deploy.$DEPLOYMENT_ENVIRONMENT.env"

if [[ ! -f deploy.env ]] && [[ ! -f $PER_ENV_FILE ]]
then
  echo "WARNING: neither deploy.env nor $PER_ENV_FILE we found, creating empty ones."
fi

touch -a deploy.env
touch -a $PER_ENV_FILE

echo "DEPLOYMENT_ENVIRONMENT = $DEPLOYMENT_ENVIRONMENT"

export CLOUDREACTOR_TASK_VERSION_SIGNATURE=`git rev-parse HEAD`
echo "CLOUDREACTOR_TASK_VERSION_SIGNATURE = $CLOUDREACTOR_TASK_VERSION_SIGNATURE"

docker run --rm \
 -e DEPLOYMENT_ENVIRONMENT \
 -e CLOUDREACTOR_TASK_VERSION_SIGNATURE \
 --env-file deploy.env \
 --env-file $PER_ENV_FILE \
 -v /var/run/docker.sock:/var/run/docker.sock \
 -v $PWD/Dockerfile:/work/docker_context/Dockerfile \
 -v $PWD/requirements.in:/work/docker_context/requirements.in \
 -v $PWD/src:/work/docker_context/src \
 -v $PWD/deploy_config:/work/deploy_config \
 cloudreactor/aws-ecs-cloudreactor-deployer ./deploy.sh "$@"
