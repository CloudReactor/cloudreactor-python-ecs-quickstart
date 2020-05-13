# AWS permissions required to deploy

Generally, an admin or a power user of AWS should be able to deploy
tasks using this example project. However, if the AWS user account
you intend to use to deploy tasks does not have sufficient permissions,
deployment won't succeed. The exact permissions needed are:

* ecr:BatchCheckLayerAvailability
* ecr:CompleteLayerUpload
* ecr:CreateRepository
* ecr:DescribeRepositories
* ecr:GetAuthorizationToken
* ecr:InitiateLayerUpload
* ecr:PutImage
* ecr:UploadLayerPart
* ecs:RegisterTaskDefinition
* iam:GetRole (to any role with name containing "taskExecutionRole")
* iam:PassRole (to any role with name containing "taskExecutionRole")

You can either add these permissions to the AWS user account that 
will be used to deploy, or upload the
[CloudReactor AWS deployer CloudFormation template](https://raw.githubusercontent.com/CloudReactor/aws-role-template/master/cloudreactor-aws-deploy-role-template.json) to CloudFormation.
For instructions on how to do that, see the 
main project page for [aws-role-template](https://github.com/CloudReactor/aws-role-template/).

Once you have the access key and secret key output by the template,
you can add them to `deploy/docker_deploy.env` if using the Docker Deployment 
method. If you're using the Native Deployment method, configure the
AWS CLI to use them using `aws configure`, or give your EC2 instance
that you deploy from the instance role output by the template.
