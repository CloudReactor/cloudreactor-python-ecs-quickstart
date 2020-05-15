# Development

## Running the tasks locally

The tasks are setup to be run with Docker Compose in `docker-compose.yml`. For example,
you can build the Docker image that runs the tasks by typing:

    docker-compose build

(You only need to run this again when you change the dependencies required by 
the project.)

Then to run, say `task_1`, type:

    docker-compose run --rm task_1

Docker Compose is setup so that changes in the environment file `build/files/.env.dev`
and the files in `src` will be available without rebuilding the image.

The web server can be started with:

    docker-compose up -d web_server

and stopped with

    docker-compose stop web_server

## Entering a shell in the image

For debugging or adding dependencies, it is useful to enter a bash shell in 
the Docker image:

    docker-compose run --rm shell

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
2. Run:
    `docker-compose run --rm pip-compile`
This will update the file `requirements.txt`.
3. Rebuild your task code:

    docker-compose build task_1

Now you can start using the dependency in your code.

### Adding another development dependency

Development dependencies are libraries used during development and
testing but not used when the tasks are deployed. For example, `pytest`
is a development dependency because it is needed to run tests during
development, but not needed to run the actual tasks.

To adding a python library to your development dependencies, follow these 
steps:

1. Add the library name to `dev-requirements.in`
2. Run:

    docker-compose run --rm pip-compile dev-requirements.in --output-file dev-requirements.txt

This will update the file `dev-requirements.txt`.
3. If necessary, add another service to `docker-compose.yml` that runs
the development task. Also build your development task image:

    docker-compose build <task name>

where `<task_name>` is the name of the service you added in step 3.

Now you can start using the development dependency.

## Running tests

This project uses the [pytest](https://docs.pytest.org/en/latest/)
framework to run tests. The test code is located in `/tests`. For
now there is only a trivial test which you can delete once you've
added your own. To run tests:

    docker-compose run --rm pytest

## View test coverage

This project uses the [pytest-cov]https://github.com/pytest-dev/pytest-cov)
framework to report test coverage. To get a report:

    docker-compose run --rm pytest-cov
