/*other modules can use these outputs to reference the S3 buckets */
output "raw_bucket_name" {
  value = aws_s3_bucket.ia_test_raw_documents.bucket
}

output "raw_bucket_arn" {
  value = aws_s3_bucket.ia_test_raw_documents.arn
}

output "processed_bucket_name" {
  value = aws_s3_bucket.ia_test_processed_documents.bucket
}

output "processed_bucket_arn" {
  value = aws_s3_bucket.ia_test_processed_documents.arn
}

output "raw_bucket_id" {
  value = aws_s3_bucket.ia_test_raw_documents.id
} 
output "processed_bucket_id" {
  value = aws_s3_bucket.ia_test_processed_documents.id
}