variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "environment" {
  type        = string
  description = "Environment. Possible values are: Dev, Uat, Prod"
}

variable "github_repository" {
  type        = string
  description = "This github repository"
  default     = "pagopa/interop-infra-att-eservices"
}

variable "dynamodb_table" {
  type        = string
  description = "DynamoDB table name that holds tfstate"
}


variable "tags" {
  type = map(any)
  default = {
    "CreatedBy" : "Terraform",
    "Environment" : ""
  }
}
