resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace
  }

  depends_on = [module.eks]
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
    "KMS_KEYID"                   = aws_kms_key.interop_client_key.id,
    "REDIS_ENDPOINT"              = "redis://${module.redis.elasticache_replication_group_primary_endpoint_address}:${module.redis.elasticache_port}",
    "NAMESPACE"                   = var.namespace,
    "SERVICEACCOUNT"              = kubernetes_service_account.service_account.metadata.0.name,
    "RESIDENCEVERIFICATIONIMAGE"  = format("%s.dkr.ecr.%s.amazonaws.com/%s:%s", data.aws_caller_identity.current.account_id, var.aws_region, "interop-att-eservice-residence-verification", replace(var.reference_branch, "/", "-")),
    "FISCALCODEVERIFICATIONIMAGE" = format("%s.dkr.ecr.%s.amazonaws.com/%s:%s", data.aws_caller_identity.current.account_id, var.aws_region, "interop-att-eservice-fiscalcode-verification", replace(var.reference_branch, "/", "-")),
    "DATABASE_URL"                = format("%s:%s", module.aurora_postgresql_v2.cluster_endpoint, module.aurora_postgresql_v2.cluster_port)
    "DATABASE_USERNAME"           = format("%s", module.aurora_postgresql_v2.cluster_master_username),
    "DATABASE_PASSWORD"           = format("%s", random_password.master.result),
    "DATABASE_NAME"               = format("%s", module.aurora_postgresql_v2.cluster_database_name),
    "DATABASE_SCHEMA"             = format("%s", module.aurora_postgresql_v2.cluster_master_username),
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

  field_manager {
    force_conflicts = true
  }
}

# DEPLOYMENT
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

# SERVICE
data "http" "service_manifestfile" {
  for_each = toset(var.packages)
  url      = "https://raw.githubusercontent.com/pagopa/interop-att-eservices/${var.reference_branch}/packages/${each.key}/kubernetes/${var.environment}/service.yaml"
}

resource "kubernetes_manifest" "service" {
  for_each = data.http.service_manifestfile
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

# ingress
resource "kubernetes_ingress_v1" "eks_ingress" {
  metadata {
    name      = "interop-att-eservices-ingress"
    namespace = kubernetes_namespace.namespace.metadata.0.name
    annotations = {
      "kubernetes.io/ingress.class"           = "alb"
      "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"
    }
  }
  spec {
    rule {
      host = var.ingress_hostname
      http {
        path {
          path      = "/residence-verification"
          path_type = "Prefix"
          backend {
            service {
              name = "interop-att-residence-verification"
              port {
                number = 3000
              }
            }
          }
        }
      }
    }
  }
}

resource "tls_private_key" "mtls" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "mtls" {
  private_key_pem = tls_private_key.mtls.private_key_pem

  subject {
    common_name  = var.ingress_hostname
    organization = "Custom Org, Inc"
  }

  validity_period_hours = 1051200

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "mtls" {
  private_key      = tls_private_key.mtls.private_key_pem
  certificate_body = tls_self_signed_cert.mtls.cert_pem
}



# ingress
resource "kubernetes_ingress_v1" "eks_mtls_ingress" {
  metadata {
    name      = "interop-att-eservices-mtls-ingress"
    namespace = kubernetes_namespace.namespace.metadata.0.name
    annotations = {
      "kubernetes.io/ingress.class"                     = "alb"
      "alb.ingress.kubernetes.io/scheme"                = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"           = "ip"
      "alb.ingress.kubernetes.io/listen-ports"          = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
      "alb.ingress.kubernetes.io/ssl-redirect"          = "443"
      "alb.ingress.kubernetes.io/healthcheck-port"      = "3000"
      "alb.ingress.kubernetes.io/healthcheck-protocol"  = "HTTP"
      "alb.ingress.kubernetes.io/healthcheck-path"      = "/fiscalcode-verification/status"
      "alb.ingress.kubernetes.io/mutual-authentication" = "[{\"port\": 80, \"mode\": \"passthrough\"}, {\"port\": 443, \"mode\": \"passthrough\"}]"
      "alb.ingress.kubernetes.io/backend-protocol"      = "HTTP"
      "alb.ingress.kubernetes.io/load-balancer-name"    = "${local.project}-mtalb"
      "alb.ingress.kubernetes.io/certificate-arn"       = aws_acm_certificate.mtls.arn
    }
  }
  spec {
    rule {
      host = "mtls.${var.ingress_hostname}"
      http {
        path {
          path      = "/fiscalcode-verification"
          path_type = "Prefix"
          backend {
            service {
              name = "interop-att-fiscalcode-verification"
              port {
                number = 3000
              }
            }
          }
        }
      }
    }
  }
}