# Additional configuration

The project allows for many configuration options to be set or overridden: 

* You can override the common task configuration in each task's configuration in 
the `task_name_to_config` property of `deploy/common.yml`
* Your deployment environment can override the AWS configuration,
the CloudReactor API key, and per task configuration in `deploy/<environment>.yml`.
See `deploy/example.yml` for instructions.
* You can add additional properties to the main container running each task, 
such as `mountPoints` and `portMappings`  by setting   
`extra_main_container_properties` in common.yml or `deploy/<environment>.yml`.
See the `file_io` task for an example of this.
* You can add AWS ECS task properties, such as `volumes` and `secrets`, 
by setting `extra_task_definition_properties` in the `ecs` property of each task
configuration. See the `file_io` task for an example of this.
* You can add additional containers to the task by setting `extra_container_definitions`
in `deploy/common.yml` or `deploy/<environment>.yml`.
* To deploy non-python projects, change `deploy/Dockerfile` to have the dependencies
needed to build your project (JDK, C++ compiler, etc.). Then, if necessary, 
add a build step to `deploy/deploy.yml` (search for "maven") to see an example.
