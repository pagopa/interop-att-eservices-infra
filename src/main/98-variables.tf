variable "aws_region" {
  type        = string
  description = "AWS region to create resources. Default Milan"
  default     = "eu-south-1"
}

variable "app_name" {
  type        = string
  description = "App name."
  default     = "interop-att-eservices"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment. Possible values are: dev, uat, prod"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.1.0.0/16"
  description = "VPC cidr."
}

variable "azs" {
  type        = list(string)
  description = "Availability zones"
  default     = ["eu-south-1a", "eu-south-1b", "eu-south-1c"]
}

variable "cluster_version" {
  description = "Kubernetes <major>.<minor> version to use for the EKS cluster (i.e.: 1.24)"
  default     = "1.29"
  type        = string
}

## Public Dns zones
##  variable "public_dns_zones" {
##  type        = map(any)
##  description = "Route53 Hosted Zone"
##}

variable "tags" {
  type = map(any)
  default = {
    CreatedBy = "Terraform"
  }
}

variable "aurora_rds_cluster_min_capacity" {
  description = "Aurora serverless cluster min capacity"
  type        = number
  default     = 2
}

variable "aurora_rds_cluster_max_capacity" {
  description = "Aurora serverless cluster max capacity"
  type        = number
  default     = 2
}

variable "helm_aws_load_balancer_version" {
  type        = string
  description = "Helm Chart AWS Load balancer controller version"
}

variable "helm_metrics_server_version" {
  type        = string
  description = "Helm Chart Metrics Server version"
}

variable "helm_prometheus_version" {
  type        = string
  description = "Helm Chart Metric Server version"
}

variable "helm_reloader_version" {
  type        = string
  description = "Helm Chart Reloader version"
}

variable "time_response_thresholds" {
  default = {
    period    = "60" //Seconds
    statistic = "Average"
    threshold = "30" //Seconds
  }
}

variable "fiveXXs_thresholds" {
  default = {
    period    = "60" //Seconds
    statistic = "Average"
    threshold = "1" //Count
  }
}

variable "packages" {
  type        = list(any)
  description = "Packages of att-services repository"
  default     = ["residence-verification", "fiscalcode-verification"]
}

variable "reference_branch" {
  type        = string
  description = "Reference branch for k8s files"
}

variable "namespace" {
  type        = string
  description = "Namespace for att microservices"
  default     = "att"
}

variable "ingress_hostname" {
  type        = string
  description = "FQDN of interop att eservices"
}

