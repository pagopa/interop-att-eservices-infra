output "backend_bucket_name" {
  value = aws_s3_bucket.terraform_states.bucket
}

output "aws_iam_role_githubiac_name" {
  value = aws_iam_role.githubiac.name
}