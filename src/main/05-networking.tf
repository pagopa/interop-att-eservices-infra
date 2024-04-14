module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.1.2"

  name = "${local.project}-vpc"

  cidr            = var.vpc_cidr
  azs             = var.azs
  public_subnets  = [for k, v in var.azs : cidrsubnet(var.vpc_cidr, 8, k)]
  private_subnets = [for k, v in var.azs : cidrsubnet(var.vpc_cidr, 8, k + 48)]

  map_public_ip_on_launch = false

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_flow_log                                 = true
  create_flow_log_cloudwatch_iam_role             = true
  create_flow_log_cloudwatch_log_group            = true
  flow_log_cloudwatch_log_group_retention_in_days = 1
  flow_log_cloudwatch_log_group_name_prefix       = "/aws/vpc/${local.project}/"

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = var.tags
}




