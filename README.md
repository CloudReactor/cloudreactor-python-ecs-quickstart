# CloudReactor ECS Python Quickstart

![Tests](https://github.com/CloudReactor/cloudreactor-python-ecs-quickstart/workflows/Tests/badge.svg?branch=master)

<img src="https://img.shields.io/github/license/CloudReactor/cloudreactor-python-ecs-quickstart.svg?style=flat-square" alt="License">

This project serves as blueprint to get your python code
running in [AWS ECS Fargate](https://aws.amazon.com/fargate/),
monitored and managed by
[CloudReactor](https://www.cloudreactor.io/). See a
[summary of the benefits](https://docs.cloudreactor.io/cloudreactor.html)
of these technologies.
This project is designed with best practices and smart defaults in mind, but also to be customizable.

It has these features built-in:
* Runs, tests, and deploys everything with Docker, no local python installation required
* Deploys to AWS ECS Fargate. Tasks can be scheduled, used as services, or executed only on demand.
* Sets up tasks to be monitored and managed by CloudReactor
* Uses [pip-tools](https://github.com/jazzband/pip-tools) to manage only
top-level python library dependencies
* Uses [pytest](https://docs.pytest.org/en/latest/) (automated tests),
[pylint](https://www.pylint.org/) (static code analysis),
[mypy](http://mypy-lang.org/) (static type checking), and
[safety](https://github.com/pyupio/safety) (security vulnerability checking)
for quality control
* Uses [GitHub Actions](https://github.com/features/actions) for
Continuous Integration (CI) and Continuous Deployment (CD)

## How it works

This project deploys tasks by doing the following:

1) Build the Docker image and send it to AWS ECR
2) Create an ECS Task Definition and installs it in ECS
3) Create or update a CloudReactor Task that is linked to the ECS
Task Definition, so that it can manage it

The deployment method uses the
[aws-ecs-cloudreactor-deployer](https://github.com/CloudReactor/aws-ecs-cloudreactor-deployer)
Docker image to build and deploy your tasks.
(This is not to be confused with the Docker container that actually runs your tasks.)
The deployer Docker image has all the dependencies (python, ansible, aws-cli etc.)
built-in, so you don't need to install anything directly on your machine.

Sound good? OK, let's get started!

## Pre-requisites

First, setup AWS and CloudReactor by following the
[pre-requisites](https://docs.cloudreactor.io/full_integration.html#pre-requisites).
You'll be granting CloudReactor permission to start Tasks on your behalf,
creating API keys, and optionally creating an IAM user/role that has permission
to deploy your Tasks.

## Get this project's source code

Next, you'll need to get this project's source code onto a filesystem where you
can make changes. First
[fork](https://docs.github.com/en/github/getting-started-with-github/fork-a-repo)
the project, then clone your project:

    git clone https://github.com/YourOrg/cloudreactor-python-ecs-quickstart.git

## Deploy the Tasks to AWS ECS and CloudReactor

Afterwards, follow the remaining instructions starting from
[Set Task properties](https://docs.cloudreactor.io/full_integration.html#set-task-properties).
You'll be setting the API keys and AWS credentials, optionally in a secure
way using Secrets Manager. Finally, you'll deploy the Tasks with the command

    ./cr_deploy.sh <environment>

or a wrapper script that calls `cr_deploy.sh` with some options.

## Deploying with the GitHub Action

This project is configured to use the deployer image as a [GitHub Action](https://github.com/marketplace/actions/cloudreactor-aws-ecs-deployer). After
forking the source code, you should set these secrets in your GitHub account:

* AWS_ACCESS_KEY_ID
* AWS_SECRET_ACCESS_KEY
* CLOUDREACTOR_DEPLOY_API_KEY

For other configuration properties, view or modify
[`push.yml`](.github/workflows/push.yml)
which configures the GitHub Action.
You should change the `aws-region` to the region containing your ECS
Cluster, and set the `CLOUDREACTOR_API_BASE_URL` secret value to
`https://api.cloudreactor.io`. You may also want to change the
`deployment-environment` to the name of your deployment environment
(it defaults to `staging`).

## The example Tasks

Successfully deploying this example project will create two ECS tasks which are
listed in `deploy_config/common.yml`. They have the following behavior:

* *task_1* also prints 30 numbers and exits successfully. While it does so,
it updates the successful count and the last status message that is shown in
CloudReactor, using the status updater library. It is scheduled to run daily.
* *file_io* uses [non-persistent file storage](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/fargate-task-storage.html) to write and read numbers
* *web_server* uses a python library dependency (Flask) to implement a web
server and shows how to link an AWS Application Load Balancer (ALB) to a service.
It requires that an ALB and target group be setup already, so it is not enabled by default.
If enabling, you should also uncomment this line in the Dockerfile to allow the
container to receive inbound requests:

    EXPOSE 7070

## Development workflow

### Running the tasks locally

The tasks are setup to be run with Docker Compose in `docker-compose.yml`. For example,
you can build the Docker image that runs the tasks by typing:

    docker compose build

(You only need to run this again when you change the dependencies required by
the project.)

Then to run, say `task_1`, type:

    docker compose run --rm task_1

Docker Compose is setup so that changes in the environment file `deploy_config/files/.env.dev`
and the files in `src` will be available without rebuilding the image.


## Deploying your own tasks

Now that you have deployed the example tasks, you can move your existing code to
this project. You can add or modify tasks in `deploy_config/common.yml` to call
the commands you want, with configuration for the schedule, retry parameters,
and environment variables.
Feel free to delete the tasks that you don't need, just by removing the top
level keys in `task_name_to_config`.

## More development options

See the [development guide](docs/development.md) for instructions on how to debug,
add dependencies, and run tests and checks.

To deploy non-python projects, it may be sufficient to add pre and post build
steps to `deploy_config/hooks`. If you require additional dependencies
(like compilers) to be installed during build time, see the
[aws-ecs-cloudreactor-deployer](https://github.com/CloudReactor/aws-ecs-cloudreactor-deployer)
project for ways to add dependencies. One way to avoid adding dependencies is
[multi-stage Dockerfiles](https://docs.docker.com/develop/develop-images/multistage-build/).

## Next steps

* [Additional configuration](https://docs.cloudreactor.io/configuration.html)
options can be set or overridden
* If you want to be alerted when Task Executions fail, setup an
[Alert Method](https://docs.cloudreactor.io/alerts.html)
* To avoid leaking secrets (passwords, API keys, etc.), see the guide on
[secret management](https://docs.cloudreactor.io/secrets.html)
* For more secure [networking](https://docs.cloudreactor.io/networking.html), run your tasks on private subnets
and/or tighten your security groups.
* If you're having problems, see the
[troubleshooting guide](https://docs.cloudreactor.io/troubleshooting.html)

## Contact us

Hopefully, this example project has helped you get up and running with ECS and
CloudReactor. Feel free to reach out to us at support@cloudreactor.io
if you have any questions or issues!
