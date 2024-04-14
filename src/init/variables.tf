variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "github_repository" {
  type        = string
  description = "This github repository"
  default     = "pagopa/interop-infra-att-eservices"
}

variable "tags" {
  type = map(any)
  default = {
    "CreatedBy" : "Terraform",
    "Environment" : ""
  }
}
