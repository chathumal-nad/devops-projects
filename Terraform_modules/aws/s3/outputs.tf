output "base_bucket_policy" {
  value       = data.aws_iam_policy_document.bucket_policy.json
  description = "Base policy for the S3 bucket"
}

output "bucket_arn" {
  value       = aws_s3_bucket.s3.arn
  description = "The ARN of the S3 bucket"
}

output "bucket_id" {
  value       = aws_s3_bucket.s3.id
  description = "The ID of the S3 bucket"
}

