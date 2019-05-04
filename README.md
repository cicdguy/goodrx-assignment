# GoodRx DevOps Homework


## Automation

I abstracted the automation processes into a Makefile. You can run `make list` to see what Make targets are available. In order to run the make commands, you must set the AWS credentials as environment variables. I've made provisions to set the Docker Hub password as an environment variable as well, so that Docker image deployments to Docker Hub can be automated.

```shell
$ make list
all
check-aws-env
check-docker-env
docker-build
docker-publish
docker-run
tf-apply
tf-destroy
tf-fmt
tf-infra
tf-init
tf-plan
```

Read below to see how some of these targets were used.

## The API

I used Flask-RestPlus to create the API. You'll find the code in the [app](app) directory. It can be run locally or via a Docker container.

I used the `make docker-*` commands to automatically build the Docker image and push it into Docker Hub at [this location](https://hub.docker.com/r/dinakar29/goodrx-api).


The Swagger UI is available at [http://goodrx-api-demo-alb-1203638726.eu-west-2.elb.amazonaws.com](http://goodrx-api-demo-alb-1203638726.eu-west-2.elb.amazonaws.com). You may interact with the `builds` API at [http://goodrx-api-demo-alb-1203638726.eu-west-2.elb.amazonaws.com/builds](http://goodrx-api-demo-alb-1203638726.eu-west-2.elb.amazonaws.com/builds) via POST operations. There is also a health check endpoint at [http://goodrx-api-demo-alb-1203638726.eu-west-2.elb.amazonaws.com/health](http://goodrx-api-demo-alb-1203638726.eu-west-2.elb.amazonaws.com/health) which the load balancer uses to check the health of the API.

## Terraform

Terraform code can be found under the [terraform](terraform) directory. I used the `make tf-infra` command to automatically provision the AWS infrastructure. I've provided a list of inputs and outputs used by the code:

### Terraform Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| allowed\_ssh\_ips | CIDR blocks allowed for SSH access | list | `<list>` | no |
| app\_name | Name of the application | string | `"goodrx-api"` | no |
| app\_port | App port to be served | string | `"80"` | no |
| availability\_zones | List of availability zones | list | `<list>` | no |
| aws\_access\_key | AWS access key (AWS_ACCESS_KEY_ID). | string | `""` | no |
| aws\_region | AWS region | string | `"eu-west-2"` | no |
| aws\_secret\_key | AWS secret key (AWS_SECRET_ACCESS_KEY). | string | `""` | no |
| environment | App environment | string | `"demo"` | no |
| instance\_type | Instance type | string | `"t2.micro"` | no |
| public\_subnet\_az1\_cidr | CIDR for az1 public subnet | string | `"10.0.20.0/24"` | no |
| public\_subnet\_az2\_cidr | CIDR for az2 public subnet | string | `"10.0.21.0/24"` | no |
| ssh\_port | Port for SSH access | string | `"22"` | no |
| vpc\_cidr | CIDR for VPC | string | `"10.0.0.0/16"` | no |

### Terraform Outputs

| Name | Description |
|------|-------------|
| alb\_address | FQDN for the ALB |
| instance\_ip | Instance IP |

You can destroy the environment by invoking `make tf-destroy`

## Config Management

I did not use any of the traditional config management tools such as Ansible, Chef, Puppet or Salt to install dependencies on the EC2 instance, since the API was dockerized. I installed Docker on a Ubuntu 16.04 instance with cloud-init and started the container when the instance came up.
