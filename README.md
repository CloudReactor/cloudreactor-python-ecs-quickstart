# CloudReactor ECS Quickstart

![Tests](https://github.com/CloudReactor/cloudreactor-ecs-quickstart/workflows/Tests/badge.svg?branch=master)

This project serves as blueprint to get your python code
running in [AWS ECS Fargate](https://aws.amazon.com/fargate/), 
monitored and managed by
[CloudReactor](https://www.cloudreactor.io/). See [Benefits](docs/benefits.md)
for a summary of the benefits of these technologies. This project is designed with best practices and smart defaults in mind, but also to be customizable.

It has these features built-in:
* Runs, tests, and deploys everything with Docker, no local python installation required
* Deploys to AWS ECS Fargate, tasks can be scheduled or used as services
* Sets up tasks to be monitored and managed by CloudReactor
* Uses [pip-tools](https://github.com/jazzband/pip-tools) to manage only 
top-level python library dependencies
* Uses [pytest](https://docs.pytest.org/en/latest/) (testing), 
[pylint](https://www.pylint.org/) (static code analysis),  
[mypy](http://mypy-lang.org/) (static type checking), and
[safety](https://github.com/pyupio/safety) (security vulnerability checking)
for quality control
* Uses [GitHub Actions](https://github.com/features/actions) for Continuous Integration (CI)

Sound good? OK, let's get started!

## Setup ECS

If you haven't yet setup ECS Fargate in your AWS account, follow the steps below.

Note that setting up ECS Fargate (as below) is entirely separate from setting up CloudReactor.

### Use the ECS First Run wizard

The AWS console provides a wizard that creates an ECS cluster in just a few 
steps. This is appropriate if you want to get started quickly.
The wizard can optionally create a new VPC and new public subnets
on that VPN, but cannot create [private subnets](docs/networking.md). 

To run the wizard, your account needs to have the permissions listed under
"Amazon ECS First Run Wizard Permissions" on this 
[page](https://docs.aws.amazon.com/AmazonECS/latest/userguide/security_iam_id-based-policy-examples.html).

The steps to run the wizard are:

1. Go to https://aws.amazon.com/ecs/getting-started/
2. Click the `ECS console walkthrough` button
3. Log in to AWS if necessary
4. Change the region to your default AWS region
5. Click the `Get started` button
6. Choose the `nginx` container image and click the `Next` button
7. On the next page, the defaults are sufficient, so hit `Next` again
8. On the next page, name your cluster the desired name of your deployment environment -- for example `staging`. If you have an existing VPC and subnets you want to use to run your tasks, you can select them here. Otherwise, the console will create a new VPC and subnets for you.
After entering your desired cluster name, hit `Next` again.
9. On the next and final page, review your settings and hit the `Create` button. You'll see the status of the created resources on the next page. **If you didn't choose existing subnets, record the subnet IDs -- we'll use them for the deployment of this project.**

After these steps, AWS should create:

1) A cluster named as you chose on step 8 above.
2) A VPC named `ECS [cluster name] - VPC`
3) 2 subnets in the VPC named `ECS [cluster name] - Public Subnet 1` and `ECS [cluster name] - Public Subnet 2`.
You can see these in VPC .. Subnets. Note that these subnets are public; if you 
want to use private subnets, you'll have to create your own. 
**Record the Subnet IDs -- we'll add them to the Run Environment in CloudReactor.**
4) A security group named `ECS staging - ECS Security Group` in the VPC.
You can find it in `VPC .. Security Groups`. 
**Record the Security Group ID, we'll add it to the Run Environment in CloudReactor.**
5) Once you've recorded the Subnet IDs and Security Group IDs, under "ECS resource creation", you'll see `Cluster [the name of the cluster you created]`. Clicking this link will take you to the cluster's details page; **record the `Cluster ARN`** you see here.

At this point, you have a working ECS environment. 

## Give CloudReactor permissions

To have CloudReactor manage your tasks in your AWS environment, you'll need
to give CloudReactor permissions in AWS to run tasks, schedule tasks,
create services, and trigger Workflows by deploying the
[CloudReactor AWS CloudFormation template](https://github.com/CloudReactor/aws-role-template),
 named `cloudreactor-aws-role-template.json`.
Follow the instructions in the [README.md](https://github.com/CloudReactor/aws-role-template/blob/master/README.md), 
in the section "Allowing CloudReactor to manage your tasks".
Be sure to record the ```ExternalID```, ```CloudreactorRoleARN```, ```TaskExecutionRoleARN```,
```WorkflowStarterARN```, and ```WorkflowStarterAccessKey``` values.

## Select or create user and/or role for deployment

You'll need an AWS user or role capable of deploying Docker images to ECR and creating tasks in ECS.
You can either:

1) Use an admin user or a power user with broad permissions; or, 
2) Create a user and role with specific permissions for deployment using another 
the [CloudReactor AWS deployer CloudFormation template](https://github.com/CloudReactor/aws-role-template).

For more details, see [AWS permissions required to deploy](doc/deployer_aws_permissions.md).

## Set up a CloudReactor account

Contact us at support@cloudreactor.io and we'll create an account for you
and give you an API key.
Then login to the [CloudReactor dashboard](https://dash.cloudreactor.io/). 
Now you'll create a Run Environment -- these settings tell CloudReactor how to run tasks in AWS.

1. Click on "Run Environments", then "Add Environment"
2. Name your environment (e.g. "staging", "production"). You may want to keep the
name in all lowercase letters without spaces or symbols besides "-" and "_", so
that filenames and command-lines you'll use later will be sane. 
**Note the exact name of your Run Environment**, as you'll need this later.
3. Fill in your AWS account ID and default region. Your AWS account ID is a 12-digit number that you can find by clicking "Support" then "Support Center". For default region, select the region that you want CloudReactor to run tasks / workflows in (e.g.`us-west-2`).
4. For `Assumable Role ARN`
fill in the value of `CloudreactorRoleARN` from the output of the CloudFormation stack.
5. For `External ID`, use the same External ID you entered when you created the CloudFormation stack.
6. For `Workflow Starter Lambda ARN`, fill in the value of `WorkflowStarterARN` from the output of the CloudFormation stack.
7. For `Workflow Starter Access Key`, fill in the value of `WorkflowStarterAccessKey` from the output of the CloudFormation stack.
8. Add the subnets and security group created by the ECS getting started wizard above
9. Under AWS ECS Settings, choose a `Default Launch Type` of `Fargate` and check FARGATE under Supported Launch Types.
10. For `Default Cluster ARN`, fill in the `Cluster ARN` of the ECS cluster you created above
11. For `Default Execution Role` and `Default Task Role`, fill in the value of
`TaskExecutionRoleARN` from the output of the CloudFormation stack.
12. Click on the `Save` button

## Get this project's source code

You'll need to get this project's source code onto a filesystem where you can make changes.
You can either clone this project directly, or fork it first, then clone it.

If cloning directly,

    git clone https://github.com/CloudReactor/cloudreactor-ecs-quickstart.git

## Deploy the tasks to AWS and CloudReactor

These steps show how you can deploy the example project in this repo to ECS Fargate
and have its tasks managed by CloudReactor. There are two methods of doing so,
Docker Deployment and Native Deployment. 

### Docker Deployment

This deployment method builds a Docker container that is used to build and 
deploy your tasks.
(This is not to be confused with the Docker container that actually runs your tasks.)
The Docker container has all the dependencies (python, ansible, aws-cli etc.)
built-in, so you don't need to install anything directly on your machine. 
The Docker deployment method is appropriate for when 

* you don't have python installed directly on your machine; or
* you don't want add another set of dependencies to your libraries; or 
* you need to deploy from a Windows machine.

You can also use this method on an EC2 instance that has an instance profile 
containing a role that has permissions to create ECS tasks. When deploying, the
AWS CLI in the container will use the temporary access key associated with the
role assigned to the EC2 instance.

The steps for Docker Deployment are:

1. Ensure you have Docker running locally, and have installed
[Docker Compose](https://docs.docker.com/compose/install/).   
2. Copy `deploy/docker_deploy.env.example` to `deploy/docker_deploy.env` and
and fill in your AWS access key, access key secret, and default
region. The access key and secret would be for the AWS user you plan on using to deploy with,
possibly created in the section "Select or create user and/or role for deployment".
You may also populate this file with a script you write yourself,
for example with something that uses the AWS CLI to assume a role and gets
temporary credentials. If you are running this on an EC2 instance with an instance profile
that has deployment permissions, you can leave this file blank.
3. Copy `deploy/vars/example.yml` to `deploy/vars/<environment>.yml`, where 
`<environment>` is the name of the Run Environment created above (e.g. 
`staging`, `production`)
4. Open the .yml file you just created, and enter your CloudReactor API key next 
to "api_key"
5. Build the Docker container that will deploy the project. In a bash shell, run:

    `./docker_build_deployer.sh <environment>`
    
   In a Windows command prompt, run:
   
    `docker_build_deployer <environment>`
    
`<environment>` is a required argument, which is the name of the Run Environment.     
    
This step is only necessary once, unless you add additional configuration
to `deploy/Dockerfile`.

6) To deploy, in a bash shell, run:

    `./docker_deploy.sh <environment> [task_name]` 
    
   In a Windows command prompt, run:
   
    `docker_deploy <environment>  [task_names]`
    
In both of these commands, `<environment>` is a required argument, which is the
name of the Run Environment. `[task_names]` is an optional argument, which is a
comma-separated list of tasks to be deployed. In this project, this can be one 
or more of `task_1`, `file_io`, etc, separated by commas. 
If `[task_names]` is omitted, all tasks will be deployed.
  
To troubleshoot deployment issues, in a bash shell, run 

    ./docker_deploy_shell.sh <environment> 
    
   In a Windows command prompt, run:
   
    docker_deploy_shell.bat <environment>

These commands will take you to a bash shell inside the deployer Docker 
container where you can re-run the deployment script with `./deploy.sh`
and inspect the files it produces in the `build/` directory.
  
### Native Deployment

This deployment method installs dependencies on your machine that are needed to deploy
the project. It may either be installed in the system python environment or in 
a [virtual environment](https://docs.python.org/3/tutorial/venv.html). 
Native deployment is appropriate for when
 
* you want to deploy from a Linux or Mac OS X machine (virtual machines included); and, 
* you have python installed on the machine (possibly in a virtual environment); and,
* you want to use python running directly on the machine to deploy the project.

It has the advantage that you can use the AWS configuration you 
already have set up on that machine for the AWS CLI.
 
This method most likely will not work on Windows machines, though it has
not been tested.

The steps for Native Deployment are: 

1. Ensure you have Docker running locally
2. If desired, create and use a virtual environment for deployment dependencies.
The virtual environment should use python 3.8.x. 
3. Run

    `pip install -r deploy/requirements.txt`

4. Configure the AWS CLI using `aws configure`. 
The access key and secret would be for the AWS user you plan on using to deploy with,
possibly created in the section "Select or create user and/or role for deployment".  
You can skip this step if you are deploying from an EC2 instance that you assign
an instance role that has the required permissions.
5. Copy `deploy/vars/example.yml` to `deploy/vars/<environment>.yml`, where 
`<environment>` is the name of the Run Environment created above (e.g. 
`staging`, `production`)
6. Modify `deploy/vars/<environment>.yml` to contain your CloudReactor API key
7. To deploy,

    `./deploy.sh <environment> [task_names]`

where `<environment>` is a required argument, which is the
name of the Run Environment. `[task_names]` is an optional argument, which is a
comma-separated list of tasks to be deployed. In this project, this can be one or more of 
`task_1`, `file_io`, etc, separated by commas. If `[task_names]` is omitted, all tasks will be deployed.

## The example tasks

Successfully deploying this example project will create two ECS tasks which are
listed in `deploy/common.yml`. They have the following behavior:

* *task_1* also prints 30 numbers and exits successfully. While it does so,
it updates the successful count and the last status message that is shown in
CloudReactor, using the status updater library. It is scheduled to run daily.
* *file_io* uses [non-persistent file storage](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/fargate-task-storage.html) to write and read numbers
* *web_server* uses a python library dependency (Flask) to implement a web 
server and shows how to link an AWS Application Load Balancer (ALB) to a service. 
It requires that an ALB and target group be setup already, so it is not enabled by default. 

## Development workflow

### Running the tasks locally

The tasks are setup to be run with Docker Compose in `docker-compose.yml`. For example,
you can build the Docker image that runs the tasks by typing:

    docker-compose build

(You only need to run this again when you change the dependencies required by 
the project.)

Then to run, say `task_1`, type:

    docker-compose run --rm task_1

Docker Compose is setup so that changes in the environment file `deploy/files/.env.dev`
and the files in `src` will be available without rebuilding the image.

### More development options

See the [development guide](docs/development.md) for instructions on how to debug, 
add dependencies, and run tests and checks.

## Deploying your own tasks

Now that you have deployed the example tasks, you can move your existing code to this
project. You can add or modify tasks in `deploy/common.yml` to call the commands you want,
with configuration for the schedule, retry parameters, and environment variables.
Feel free to delete the tasks that you don't need, just by removing the top level keys
in `task_name_to_config`.

## Next steps

* [Additional configuration](docs/configuration.md) options can be set or overridden 
* If you want to be alerted when task executions fail, setup an 
[Alert Method](docs/alerts.md)
* To avoid leaking secrets (passwords, API keys, etc.), see the guide on 
[secret management](docs/secret_management.md)
* For more secure networking, run your tasks on a [private subnet](docs/networking.md)
* If you're having problems, see the [troubleshooting guide](docs/troubleshooting.md)

## Contact us

Hopefully, this example project has helped you get up and running with ECS and
CloudReactor. Feel free to reach out to us at support@cloudreactor.io to setup 
an account, or if you have any questions or issues!
