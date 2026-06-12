


/*Lambda Document Processing Role*/
resource "aws_iam_role" "lambda-document-processing-role" {
    name = "lambda-document-processing-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "lambda.amazonaws.com"
                }
            }
        ]
    })

}
/*policy for Lambda Document Processing Role*/
resource "aws_iam_policy" "lambda-document-processing-policy" {
    name = "lambda-document-processing-policy"
    description = "Custom policy for lambda document processing role"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = [
                    "s3:GetObject",
                    "s3:PutObject",
                    "s3:ListBucket"
                ]
                Effect = "Allow"
                Resource = [
                    "${var.raw_bucket_arn}",
                    "${var.raw_bucket_arn}/*",
                    "${var.processed_bucket_arn}",
                    "${var.processed_bucket_arn}/*"
                ]
            }
        ]
    })
}

/*   attach Custom Policy to Role*/
resource "aws_iam_role_policy_attachment" "lambda-document-processing-role-attachment" {
    role = aws_iam_role.lambda-document-processing-role.name
    policy_arn = aws_iam_policy.lambda-document-processing-policy.arn 
}
/* Basic Execution Policy for Lambda */
resource "aws_iam_role_attachment" "lambda-basic-execution" {
    role = aws_iam_role.lambda-document-processing-role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}




