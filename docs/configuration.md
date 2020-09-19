# Task configuration

Configuration is used to set non-defaults in both the 
[ECS task definition](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definitions.html)
and the [CloudReactor task properties](https://apidocs.cloudreactor.io/). 

The ECS task definition is created with the Jinja2 template 
`deploy/templates/ecs_task_definition.json.j2`. 
The CloudReactor Task is created with the Jinja2 template
`deploy/templates/cloudreactor_task.yml.j2`. which produces a YAML
file that is converted to JSON before sending it CloudReactor. 

These templates use settings from the files described below.

# Configuration hierarchy

The settings are all (deeply) merged together with Ansible's Jinja2 
[combine](https://docs.ansible.com/ansible/latest/user_guide/playbooks_filters.html#combining-hashes-dictionaries) 
filter. The precedence of settings, from lowest to highest is:

1. Settings found in your Run Environment that you set via the CloudReactor dashboard
2. Deployment environment AWS settings -- found in `project_aws` in `deploy/vars/<environment>.yml`
3. Default task settings -- found in `default_task_config` in `deploy/vars/common.yml`
4. Per task settings -- found in `task_name_to_config.<task_name>` in `deploy/var/common.yml`
5. Per environment settings -- found in `default_env_task_config` in `deploy/vars/<environment>.yml`
5. Per task, per environment settings -- found in `task_name_to_env_config.<task_name>` in `deploy/vars/<environment>.yml`
* Your deployment environment can override the AWS configuration,
the CloudReactor API key, and per task configuration in `deploy/vars/<environment>.yml`.
See `deploy/vars/example.yml` for instructions.

## ECS Task Definition settings:

* You can add additional properties to the main container running each task, 
such as `mountPoints` and `portMappings`  by setting   
`extra_main_container_properties` in common.yml or `deploy/vars/<environment>.yml`.
See the `file_io` task for an example of this.
* You can add AWS ECS task properties, such as `volumes` and `secrets`, 
by setting `extra_task_definition_properties` in the `ecs` property of each task
configuration. See the `file_io` task for an example of this.
* You can add additional containers to the task by setting `extra_container_definitions`
in `deploy/vars/common.yml` or `deploy/vars/<environment>.yml`.


## Setting management

We recommend that you keep as many default settings in CloudReactor as possible and don't
override them in your project unless required.
To manage a setting in the CloudReactor UI, omit the property name and value. That will
tell CloudReactor to use the value that you have set either in the Task or Run Environment
editor.

It's possible that you overrode a Task setting during a previous deployment, but 
later decide to use the default value in the Run Environment. 
To do that, set the property value to null. If things still aren't working,
try removing the Task in the CloudReactor website, and re-deploying again.

