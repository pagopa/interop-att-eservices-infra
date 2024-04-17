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
reference_branch = "feature/ADA-34"
residence_verification_image_digest = ""


helm_aws_load_balancer_version = "1.7.2"
helm_metrics_server_version = "3.11.0"
helm_prometheus_version = "25.1.0"
helm_reloader_version = "1.0.44"
