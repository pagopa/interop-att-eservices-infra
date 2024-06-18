environment = "dev"

# Ref: https://pagopa.atlassian.net/wiki/spaces/DEVOPS/pages/132810155/Azure+-+Naming+Tagging+Convention#Tagging
tags = {
  CreatedBy   = "Terraform"
  Environment = "Dev"
  Owner       = "PagoPA"
  Source      = "https://github.com/pagopa/interop-infra-att-eservices"
  CostCenter  = "TS310 - PAGAMENTI e SERVIZI"
}

# change to "develop"
reference_branch = "develop"
ingress_hostname = "api.dev.interop.att.eservices.pagopa.it"

helm_aws_load_balancer_version = "1.7.2"

