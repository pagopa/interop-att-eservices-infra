output "redis_endpoint" {
  value = module.redis.elasticache_replication_group_primary_endpoint_address
}

output "aurora_postgresql_db_hostname" {
  description = "Aurora Postgresql hostname"
  value       = module.aurora_postgresql_v2.cluster_endpoint
}

output "aurora_postgresql_db_port" {
  description = "Aurora Postgresql port"
  value       = module.aurora_postgresql_v2.cluster_port
}

output "aurora_postgresql_db_name" {
  description = "Aurora Postgresql schema name"
  value       = module.aurora_postgresql_v2.cluster_database_name
}

#output "load_balancer_host" {
#  description = "DNS name of load balancer"
#  value       = data.aws_lb.load_balancer.dns_name
#}

output "att_eservices_cluster_name" {
  description = "Cluster name"
  value       = module.eks.cluster_name
}

output "interop_client_key_arn" {
  value = aws_kms_key.interop_client_key.arn
}

output "load_balancer_hostname" {
  value = kubernetes_ingress_v1.eks_ingress.status.0.load_balancer.0.ingress.0.hostname
}

output "mtls_load_balancer_hostname" {
  value = kubernetes_ingress_v1.eks_mtls_ingress.status.0.load_balancer.0.ingress.0.hostname
}