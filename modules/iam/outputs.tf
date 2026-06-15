/*Output for Lambda Document Processing Role ARN*/
output "lambda_document_processing_role_arn" {
    value = aws_iam_role.lambda_document_processing_role.arn
}

output "bedrock_role_arn" {
  value = aws_iam_role.bedrock_iam_role.arn
}

output "bedrock_agentcore_role_arn" {
  value = aws_iam_role.bedrock_agentcore_role.arn
}