# Development

## Running the tasks locally

The tasks are setup to be run with Docker Compose in `docker-compose.yml`. For example,
you can build the Docker image that runs `task_1` by typing:

    docker compose build task_1

(You only need to run this again when you change the dependencies required by
the project.)

Then to run `task_1`, type:

    docker compose run --rm task_1

Docker Compose is setup so that changes in the environment file
`deploy_config/files/.env.dev`
and the files in `src` will be available without rebuilding the image.

The web server can be started with:

    docker compose up -d web_server

and stopped with

    docker compose stop web_server

## Adding your own tasks

### Add task code

1. Place task code itself in a new file in `./src`, e.g. `new_task.py`

2. Add any required library dependencies to `/requirements.in`. For example:

    psycopg2==2.8.5

## Dependency management

This project manages its dependencies with
[pip-tools](https://github.com/jazzband/pip-tools).
Basically, you specify the top-level dependencies you need in
`requirements.in` and pip-tools will generate `requirements.txt`
which the Dockerfile uses as a list of resolved dependencies for
`pip`.

### Adding another runtime dependency

To adding a python library to your runtime dependencies, follow these steps:

1. Add the library name to `requirements.in`
2. Rebuild your task code:

    docker compose build task_1

Now you can start using the dependency in your code.
3. You should also rebuild the development requirements so that the
development tools are aware of your libraries. For example, pylint
will warn you about bad import statements unless the development Docker image
has the libraries that the main Docker image has.
To rebuild the development image so that it has these requirements, run:

    docker compose build pylint

`pylint` was used above but it could be any Docker Compose service that uses the
development image (e.g. mypy).

### Add task to manifest and Dockerfile

1. Open `./deploy/vars/common.yml`.

    You'll see entries for both `task_1` and `file_io`. E.g.:

    ```
    # This task sends status back to CloudReactor as it is running
    task_1:
        <<: *default_task_config
        description: "This description shows up in CloudReactor dashboard"
        command: "python src/task_1.py"
        schedule: cron(9 15 * * ? *)
        wrapper:
            <<: *default_task_wrapper
            enable_status_updates: true
    ```

    You can think of `common.yml` as a manifest of tasks. Running `./cr_deploy.sh` will push the files defined here to ECS, and register them with CloudReactor.

2. Add a configuration block for your new task, below `task_name_to_config:`

    The minimum required block is:

    ```
    new_task:
        <<: *default_task_config
        command: "python src/new_task.py"
    ```

    - `new_task`: a name for the configuration block
    - `<<: *default_task_config` allows new_task to inherit properties from the default task configuration
    - `command: "python src/new_task.py"` contains the command to run (in this case, to execute `new_task` via python)

    Additional parameters include the run schedule (cron expression), retry parameters, and environment variables. See (https://docs.cloudreactor.io/configuration.html) for more options.

3. (Optional) Open `/docker-compose.yml` (in the root folder). Under the section `services` add a reference to your task:

    ```
    new_task:
        <<: *service-base
        command: python src/new_task.py
    ```

  Now you can run your task locally, like this:

      docker compose run --rm new_task

## Tracking items processed, custom status messages

Two frequent needs when it comes to monitoring tasks is understanding how many items have been processed, and what a given task is doing.

The CloudReactor dashboard provides pre-defined fields where this information can be viewed. **If you want to see data in these fields (as opposed to blanks), you must instrument your task to send this data to CloudReactor.**

To see a working example of how to do this, see `/src/task_1.py` in the quickstart repo. Further instructions below!

### Check that status updates are enabled

In `/deploy/vars/common.yml`, look for the block starting with `wrapper: &default_task_wrapper`.

Add the line `enable_status_updates: True` inside this block if it's not there already. It should look like this:

    wrapper: &default_task_wrapper
        enable_status_updates: True

### Call `send_update` in your task

1. In your .py file in `/src/`, import the status_updater class:

        from proc_wrapper import StatusUpdater


2. Create a new instance of StatusUpdater, preferably using a `with` block:


        with StatusUpdater() as updater:
            updater.send_update(...)


3. To send a count of the number of items successfully processed:

        updater.send_update(success_count=success_num_rows)


    where `success_num_rows` is the number of rows of "successful" records processed. This number will show up as the "processed" column in the CloudReactor dashboard.

    You need to write the logic that tracks this number as part of your code (e.g. as rows are processed, increment the variable).

    Other "counts" that can be sent are below. These will show up in the relevant columns in CloudReactor.
    - `error_count`
    - `skipped_count`
    - `expected_count`

4. The CloudReactor dashboard also shows "last status message" for each task. This allows you to report custom messages during your task execution, improving visibility into what stage each task is at.

    For example a given task might report status messages such as "getting auth token", "fetching data", "saving data" etc.

    Send a custom "status message" via StatusUpdater() like this:

        updater.send_update(last_status_message="started data ingestion")

5. Bundle multiple row counts and status message into a single call like this:

        updater.send_update(success_count=success_num_rows,
                error_count=error_num_rows,
                last_status_message='finished data ingestion')

6. Cleanup if necessary. If you didn't use a `with` statement to create the StatusUpdater,
you should shut it down explicitly:

        updater.shutdown()

    StatusUpdater uses a UDP socket to send data. shutdown() ensures that socket is closed.

    Although it's good practice to clean up in this way, it's not strictly necessary since when the task finishes, all processes will end anyway.

## The example tasks

The example tasks show a few helpful features of CloudReactor that can be used in your own code.

- *task_1* prints 30 numbers and exits successfully. While it does so, it uses the CloudReactor status updater library to update the "successful" count and the "last status message" that is shown in the CloudReactor dashboard. These can be used to help track "# of rows processed successfully" or progress through the code. Note that task_1 is configured to run daily via `deploy/vars/common.yml`: `schedule: cron(9 15 * * ? *)`.
- *file_io* uses [non-persistent file storage](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/fargate-task-storage.html){:target="_blank"} to write and read numbers
- *web_server* uses a python library dependency (Flask) to implement a web server and shows how to link an AWS Application Load Balancer (ALB) to a service. It requires that an ALB and target group be setup already, so it is not enabled by default (i.e. is commented out in the `./deploy/vars/common.yml` file).

## Removing tasks
Delete tasks within the [CloudReactor dashboard](https://dash.cloudreactor.io){:target="_blank"}. This will remove the task from AWS also.

You should also remove the reference to the tasks in `./deploy/vars/common.yml`.

If you don't, when you run `./cr_deploy.sh [environment]` (without task names), this will (re-)push all tasks -- which might include tasks you had intended to remove.

You may also want to remove the task code itself from `/src/`

For example, if you want to delete the `task_1` task:
1. In [dash.cloudreactor.io](https://dash.cloudreactor.io){:target="_blank"}, hit the delete icon next to `task_1` and hit "confirm".
2. Open `./deploy/vars/common.yml` and delete the entire `task_1:` code block i.e.:

    ```python
    task_1:
    <<: *default_task_config
    description: "This description shows up in CloudReactor dashboard"
    command: "python src/task_1.py"
    schedule: cron(9 15 * * ? *)
    wrapper:
        <<: *default_task_wrapper
        enable_status_updates: true
    ```
3. Optionally, delete `/src/task_1.py`.

## Entering a shell in the container

For debugging or adding dependencies, it is useful to enter a bash shell in
the Docker container:

    docker compose run --rm shell

Running python commands is typically much faster once in the shell, compared to
running them individually with docker-compose.


## Running tests

This project uses the [pytest](https://docs.pytest.org/en/latest/)
framework to run tests. The test code is located in `/tests`. For
now there is only a trivial test which you can delete once you've
added your own. To run tests:

    docker compose run --rm pytest

## View test coverage

This project uses the [pytest-cov](https://github.com/pytest-dev/pytest-cov)
framework to report test coverage. To get a report:

    docker compose run --rm pytest-cov

## Check syntax

This project uses [pylint](https://www.pylint.org/) to check syntax. To check:

    docker compose run --rm pylint

## Type checking

This project uses [mypy](http://mypy-lang.org/) to do type checking. To check:

    docker compose run --rm mypy

The configuration for mypy is in `mypy.ini` in the project root.

## Check for security vulnerabilities

This project uses [safety](https://github.com/pyupio/safety) to
check libraries for security vulnerabilities, To check:

    docker compose run --rm safety

## Adding another development dependency

Development dependencies are libraries used during development and
testing but not used when the tasks are deployed. For example, `pytest`
is a development dependency because it is needed to run tests during
development, but not needed to run the actual tasks.

To add a python library to your development dependencies,

1. Add the library name to `dev-requirements.in`:
2. Rebuild the development image:

    docker compose build pylint

`pylint` was used above but it could be any Docker Compose service that uses the
development image (e.g. mypy).

Now you can start using the development dependency.

## Development shell

To get a bash shell in the container that has development dependencies installed:

    docker compose run --rm dev-shell

You can use this shell to run pytest, pylint, etc. with different options.

## Dockerfile linting

Use [hadolint](https://github.com/hadolint/hadolint) to ensure your Dockerfile follows
best practices:

    docker compose run --rm hadolint

## Continuous Integration using GitHub Actions

The project uses [GitHub Actions](https://github.com/features/actions) to
perform Continuous Integration (CI). It runs pytest, pylint, and mypy.
See `.github/workflows/push.yml` to customize.
