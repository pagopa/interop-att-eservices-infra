environment = "dev"

# Ref: https://pagopa.atlassian.net/wiki/spaces/DEVOPS/pages/132810155/Azure+-+Naming+Tagging+Convention#Tagging
tags = {
  CreatedBy   = "Terraform"
  Environment = "Dev"
  Owner       = "PagoPA"
  Source      = "https://github.com/pagopa/interop-infra-att-eservices"
  CostCenter  = "TS310 - PAGAMENTI e SERVIZI"
}

pdnd_api_endpoint = "https://api.uat.interop.pagopa.it/1.0"
pdnd_auth_client_id = "11368527-494b-4244-9706-b782b5443831"
pdnd_auth_token_uri = "https://auth.uat.interop.pagopa.it/token.oauth2"
pdnd_auth_jwk_uri = "https://uat.interop.pagopa.it"
pdnd_auth_audience = "auth.uat.interop.pagopa.it/client-assertion"
helm_aws_load_balancer_version = "1.7.2"
helm_metrics_server_version = "3.11.0"
helm_prometheus_version = "25.1.0"
helm_reloader_version = "1.0.44"
