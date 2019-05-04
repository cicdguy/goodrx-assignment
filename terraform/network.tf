module "vpc" {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc"

  name = "${var.app_name}-${var.environment}-vpc"
  cidr = "${var.vpc_cidr}"

  azs            = ["${var.aws_region}a", "${var.aws_region}b"]
  public_subnets = ["${local.public_subnet_cidrs}"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Name        = "VPC for ${var.app_name} in ${var.environment}"
    Environment = "${var.environment}"
  }
}
