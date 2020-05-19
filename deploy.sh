#!/bin/bash

if [ -z "$1" ]
  then
    if [ -z "$DEPLOYMENT_ENVIRONMENT" ]
        then
            echo "Usage: deploy.sh <deployment> [comma_delimited_task_names]"
            exit 1
    fi    
    export ENVIRONMENT=$DEPLOYMENT_ENVIRONMENT
  else
    export ENVIRONMENT=$1
    shift
fi

if [ -z "$1" ]
  then
    if [ -z "$TASK_NAMES" ]
      then
        export TASK_NAMES='ALL'
    fi
  else
    export TASK_NAMES=$1
    shift
fi

pushd deploy

RUNTIME_ENV_FILE="files/.env.$ENVIRONMENT"

if [ ! -f "$RUNTIME_ENV_FILE" ]
  then
    echo "Runtime .env file $RUNTIME_ENV_FILE does not exist, creating an empty one."
    touch -a $RUNTIME_ENV_FILE
fi

# So that merged configuration hashes in YAML don't cause warnings
export ANSIBLE_DUPLICATE_YAML_DICT_KEY=ignore

# Use this line if you are not encrypting secrets. If encrypting secrets, comment out this line.
ansible-playbook  deploy.yml --extra-vars "env=${ENVIRONMENT} task_names=${TASK_NAMES}" "$@";

# The following 2 options allow your project to store encrypted secrets using ansible vault.
# When ansible-playbook runs, it will detect files encrypted with ansible vault and
# decrypt them using the password supplied either by command line, external file, or script
# that outputs the password. For more details see:
# https://docs.ansible.com/ansible/latest/user_guide/vault.html

# To use secrets encrypted with ansible-vault and get the encryption password
# from the command-line during deployment, uncomment this line:
# ansible-playbook --ask-vault-pass --extra-vars "env=${ENVIRONMENT} task_names=$TASK_NAMES" "$@" deploy.yml;

# To use secrets encrypted with ansible-vault and get the encryption password
# from a file or script (more convenient for automated deployments), uncomment
# this line:
# ansible-playbook --vault-password-file my-vault-password --extra-vars "env=${ENVIRONMENT} task_names=$TASK_NAMES" "$@" deploy.yml;


# Hint: you can store your vault password in AWS S3 and write a script like this:
#
#   echo `aws s3 cp s3://widgets-co/vault_pass.$ENVIRONMENT.txt -`
#
# Assuming the machine you deploy from has permission to read this file from S3.
popd
