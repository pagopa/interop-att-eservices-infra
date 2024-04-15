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
