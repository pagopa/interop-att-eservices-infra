resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace
  }
}

module "service_account_iam_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "${local.project}-serviceaccount-role"

  role_policy_arns = {
    policy = aws_iam_policy.kms_access.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${var.namespace}:${var.app_name}"]
    }
  }
}

resource "kubernetes_service_account" "service_account" {
  metadata {
    name      = var.app_name
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.service_account_iam_role.iam_role_arn
    }
  }
}

locals {
  tokens = {
    "KMS_KEYID"                  = aws_kms_key.interop_client_key.id,
    "REDIS_ENDPOINT"             = "redis://${module.redis.elasticache_replication_group_primary_endpoint_address}:${module.redis.elasticache_port}",
    "NAMESPACE"                  = var.namespace,
    "SERVICEACCOUNT"             = kubernetes_service_account.service_account.metadata.0.name
    "RESIDENCEVERIFICATIONIMAGE" = format("%s.dkr.ecr.%s.amazonaws.com/%s:%s", data.aws_caller_identity.current.account_id, var.aws_region, "interop-att-eservice-residence-verification", replace(var.reference_branch, "/", "-"))
  }
}

# CONFIGMAP
data "http" "configmap_manifestfile" {
  for_each = toset(var.packages)
  url      = "https://raw.githubusercontent.com/pagopa/interop-att-eservices/${var.reference_branch}/packages/${each.key}/kubernetes/${var.environment}/configmap.yaml"
}

resource "kubernetes_manifest" "configmap" {
  for_each = data.http.configmap_manifestfile
  manifest = yamldecode(
    join("\n", [
      for line in split("\n", each.value.body) :
      format(
        replace(line, "/{{(${join("|", keys(local.tokens))})}}/", "%s"),
        [
          for value in flatten(regexall("{{(${join("|", keys(local.tokens))})}}", line)) :
          lookup(local.tokens, value)
        ]...
      )
    ])
  )
}

data "http" "deployment_manifestfile" {
  for_each = toset(var.packages)
  url      = "https://raw.githubusercontent.com/pagopa/interop-att-eservices/${var.reference_branch}/packages/${each.key}/kubernetes/${var.environment}/deployment.yaml"
}

resource "kubernetes_manifest" "deployment" {
  for_each = data.http.deployment_manifestfile
  manifest = yamldecode(
    join("\n", [
      for line in split("\n", each.value.body) :
      format(
        replace(line, "/{{(${join("|", keys(local.tokens))})}}/", "%s"),
        [
          for value in flatten(regexall("{{(${join("|", keys(local.tokens))})}}", line)) :
          lookup(local.tokens, value)
        ]...
      )
    ])
  )
}



