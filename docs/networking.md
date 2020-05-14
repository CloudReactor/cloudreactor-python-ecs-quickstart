# Creating Private Subnets

The ECS Getting Started wizard only creates public subnets which can be reached
from outside your VPC. However, the best practice for security's sake is to 
run your tasks on private subnets whenever possible. 

If you want to use private subnets,
create them if you don't already have existing ones, and ensure that each subnet
has a [NAT gateway](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html)
attached to it, so that it can pull Docker images from ECR and communicate with
CloudReactor.  

For a good overview of networking in Fargate, see
[Fargate Networking 101](https://cloudonaut.io/fargate-networking-101/).