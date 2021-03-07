# CloudReactor ECS Quickstart

![Tests](https://github.com/CloudReactor/cloudreactor-ecs-quickstart/workflows/Tests/badge.svg?branch=master)

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
* Uses [pytest](https://docs.pytest.org/en/latest/) (testing),
[pylint](https://www.pylint.org/) (static code analysis),
[mypy](http://mypy-lang.org/) (static type checking), and
[safety](https://github.com/pyupio/safety) (security vulnerability checking)
for quality control
* Uses [GitHub Actions](https://github.com/features/actions) for Continuous Integration (CI)

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
The Docker container has all the dependencies (python, ansible, aws-cli etc.)
built-in, so you don't need to install anything directly on your machine.

Sound good? OK, let's get started!

## Prerequisites

Run the [CloudReactor AWS Setup Wizard](https://github.com/CloudReactor/cloudreactor-aws-setup-wizard).

This wizard:
* creates an ECS cluster if you don't already have one
* creates associated VPC, subnets and security groups (or allows you to select existing VPCs, subnets and security groups to use)
* enables CloudReactor to manage tasks deployed in your AWS account

The wizard enables you to have a working ECS environment in minutes; without it, you would need to set up each of these pieces individually which would be tedious and error-prone.

Finally, if you want to use CloudReactor to manage tasks, [create a user and role that can be used to deploy
tasks to ECS](https://docs.cloudreactor.io/#optional-setting-up-a-new-aws-user-with-deployment-permissions).
You can also use an administrator user or power user to deploy.
See [deployer AWS permissions](docs/deployer_aws_permissions.md) for a list of the permissions required.

## Get this project's source code

You'll need to get this project's source code onto a filesystem where you can make changes. First [fork](https://docs.github.com/en/github/getting-started-with-github/fork-a-repo) the project,
then clone your project:

    git clone https://github.com/YourOrg/cloudreactor-ecs-quickstart.git

## Deploy the tasks to AWS and CloudReactor

### Deployment

These steps show how you can deploy the example project in this repo to ECS Fargate
and have its tasks managed by CloudReactor.

1. Ensure you have Docker running locally, and have installed
[Docker Compose](https://docs.docker.com/compose/install/) if
running on Windows.
2. Create two API keys in CloudReactor, one for deployment and one for
your task to report its state. Go to the
[CloudReactor dashboard](https://cloudreactor.io/api_keys) and select
"API keys" in the menu that pops up when you click your username in the upper
right corner. Select the button "Add new API key..." which will take you to a
form to fill in details. Give the API key a name and associate it with the
Run Environment you created. Ensure the Group is correct, the Enabled checkbox
is checked, and the Access Level is `Task`. Then select the Save button. You
should then see your new API key listed. Copy the value of the key. This is the
`Task API key`.
3. Repeat step 2, except select the Access Level of `Developer`. The value
of the key is the `Deployment API key`.
4. Copy `deploy_config/vars/example.yml` to `deploy_config/vars/<environment>.yml`, where
`<environment>` is the name of the Run Environment created by the
CloudReactor AWS Setup Wizard (e.g.`staging`, `production`)
5. Open the .yml file you just created, and paste the value of the
`Deployment API key`:

    ```
    cloudreactor:
      deploy_api_key: PASTE_DEPLOY_API_KEY_HERE
    ```

    This allows you to your local machine (or Docker container) to
    use the CloudReactor service to deploy tasks.

6. For the `Task API key`, you have two options. The first option, which is
simpler but less secure, is to directly paste the Task API key into
`deploy_config/vars/<environment>.yml`:

    ```
    cloudreactor:
      ...
      task_api_key: PASTE_TASK_API_KEY_HERE
    ```

    The second option uses AWS Secrets Manager to store the secret and avoids the
    API key value from being part of the image. To do this, log into the AWS
    console and navigate to the AWS Secrets Manager dashboard. Select
    "Store a new secret". For "Secret Type", select "Other type of secrets" and
    "plaintext". Paste in the Task CloudReactor API key as the entire field (i.e. no need for newline, braces, quotes etc.). On the next page, for
    "secret name", type `CloudReactor/<env_name>/common/cloudreactor_api_key`,
    replacing`<env_name>` with whatever your CloudReactor Run Environment is
    called. After saving the secret, you should get a page in which you can copy
    the ARN of the secret, in the format:

        arn:aws:secretsmanager:[aws_region]:[aws_account_id]:secret:CloudReactor/example/common/cloudreactor_api_key-xxx

    Use this value to set the task_api_key value in
    `deploy_config/vars/<environment>.yml`:

        cloudreactor:
          ...
          task_api_key: PASTE_TASK_API_KEY_SECRET_ARN_HERE

    To allow your task to read the API key, it has to run with an IAM role
    that has the appropriate permission. First let's create the role in the [IAM Dashboard](https://console.aws.amazon.com/iam/home?region=us-west-2#)
    in the AWS console. It should have a policy that looks like this:

        {
          "Version": "2012-10-17",
          "Statement": {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue"
            ],
            "Resource": [
                "arn:aws:secretsmanager:[aws_region]:[aws_account_id]:secret:CloudReactor/example/common/*"
            ]
          }
        }

    where you would substitute [aws_region] with the region you stored your
    secret, and [aws_account_id] with your AWS account number.

    If you are deploying your task using ECS, the role should also have a
    trust relationship so that ECS can assume it:

        {
          "Version": "2012-10-17",
          "Statement": [
            {
              "Sid": "",
              "Effect": "Allow",
              "Principal": {
                "Service": [
                  "ecs.amazonaws.com",
                  "ecs-tasks.amazonaws.com"
                ]
              },
              "Action": "sts:AssumeRole"
            }
          ]
        }

    Once you've created the role, record the ARN which should look like:

        arn:aws:iam::012345678901:role/myapp-task-role-production

    Finally, paste the role ARN into `deploy_config/vars/<environment>.yml`:

        default_env_task_config:
          command: "python src/task_1.py"
          ecs:
            task:
              role_arn: "arn:aws:iam::012345678901:role/myapp-task-role-production"


7. Copy `deploy.env.example` to `deploy.env` and
and fill in your AWS access key, access key secret, and default
region. The access key and secret would be for the AWS user you plan on using to deploy with,
possibly created in the section "Select or create user and/or role for deployment".
You may also populate this file with a script you write yourself,
for example with something that uses the AWS CLI to assume a role and gets
temporary credentials. If you are running this on an EC2 instance with an instance profile
that has deployment permissions, you can leave this file blank.
8. To deploy, in a bash shell, run:

    `./docker_deploy.sh <environment> [task_names]`

    In a Windows command prompt, run:

    `.\docker_deploy.cmd <environment>  [task_names]`

    In both of these commands, `<environment>` is a required argument, which is the
    name of the Run Environment. `[task_names]` is an optional argument, which is a
    comma-separated list of tasks to be deployed. In this project, this can be one
    or more of `task_1`, `file_io`, etc, separated by commas.
    If `[task_names]` is omitted, all tasks will be deployed.

    To troubleshoot deployment issues, in a bash shell, run

        DEPLOYMENT_ENTRYPOINT=bash ./docker_deploy.sh <environment>

    In a bash environment with docker-compose installed:

        DEPLOYMENT_ENVIRONMENT=<environment> docker-compose -f docker-compose-deployer.yml run --rm deployer-shell

    In a Windows shell:

        set DEPLOYMENT_ENVIRONMENT=<environment>
        docker-compose -f docker-compose-deployer.yml run --rm deployer-shell

    In a Windows PowerShell:

        $env:DEPLOYMENT_ENVIRONMENT = '<environment>'
        docker-compose -f docker-compose-deployer.yml run --rm deployer-shell

    These commands will take you to a bash shell inside the deployer Docker
    container where you can re-run the deployment script with `./deploy.sh`
    and inspect the files it produces in the `build/` directory.

## The example tasks

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

    docker-compose build

(You only need to run this again when you change the dependencies required by
the project.)

Then to run, say `task_1`, type:

    docker-compose run --rm task_1

Docker Compose is setup so that changes in the environment file `deploy_config/files/.env.dev`
and the files in `src` will be available without rebuilding the image.


## Deploying your own tasks

Now that you have deployed the example tasks, you can move your existing code to this
project. You can add or modify tasks in `deploy_config/common.yml` to call the commands you want,
with configuration for the schedule, retry parameters, and environment variables.
Feel free to delete the tasks that you don't need, just by removing the top level keys
in `task_name_to_config`.

## More development options

See the [development guide](docs/development.md) for instructions on how to debug,
add dependencies, and run tests and checks.

To deploy non-python projects, it maybe sufficient to add pre and post build steps
to `deploy_config/hooks`. If you require additional dependencies (like compilers)
to be installed during build time, see the
[aws-ecs-cloudreactor-deployer](https://github.com/CloudReactor/aws-ecs-cloudreactor-deployer)
project for ways to add dependencies. A way to avoid adding dependencies is
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
CloudReactor. Feel free to reach out to us at support@cloudreactor.io to setup
an account, or if you have any questions or issues!
