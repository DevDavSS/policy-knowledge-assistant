/*Output for Lambda Document Processing Role ARN*/
output "lambda_document_processing_role_arn" {
    value = aws_iam_role.lambda_document_processing_role.arn
}

