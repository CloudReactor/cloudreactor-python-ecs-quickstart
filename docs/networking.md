# Fargate Networking

Generally, Fargate clusters are just a logical grouping. Any task in your
Fargate cluster can be assigned to any subnet you wish.

## Creating Private Subnets

The ECS Getting Started wizard only creates public subnets which can be reached
from outside your VPC. However, the best practice for security's sake is to 
run your tasks on private subnets whenever possible. 

If you want to use private subnets,
create them if you don't already have existing ones, and ensure that each subnet
has a [NAT gateway](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html)
attached to it, so that it can pull Docker images from ECR and communicate with
CloudReactor.  

## Security Groups

You must assign your Fargate tasks one or more security groups. To run in Fargate
and communicate with CloudReactor, each task must be assigned a security group
that allows all outbound access (0.0.0.0.0/0) over TCP. Inbound access is not required
unless your task handles outside requests. Generally, the security group you use
should be assigned to the VPC that hosts the subnets the task will run in.

The ECS Getting Started wizard will create a default security group attached
to the VPC it creates. The default security group is fine to use with 
CloudReactor managed tasks.

## More info

For a good overview of networking in Fargate, see
[Fargate Networking 101](https://cloudonaut.io/fargate-networking-101/).

