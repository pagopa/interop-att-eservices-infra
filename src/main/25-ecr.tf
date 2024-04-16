resource "aws_ecr_repository" "ecr" {
  for_each = toset(var.packages)
  name = "interop-att-eservice-${each.key}"
  tags = var.tags
}