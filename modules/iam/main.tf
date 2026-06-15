


/*Lambda Document Processing Role*/
resource "aws_iam_role" "lambda_document_processing_role" {
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
resource "aws_iam_policy" "lambda_document_processing_policy" {
    name = "lambda_document_processing_policy"
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
resource "aws_iam_role_policy_attachment" "lambda_document_processing_role_attachment" {
    role = aws_iam_role.lambda_document_processing_role.name
    policy_arn = aws_iam_policy.lambda_document_processing_policy.arn 
}
/* Basic Execution Policy for Lambda */
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
    role       = aws_iam_role.lambda_document_processing_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

/* Role for bedrock ------------------------------------------------------------------------------------*/

resource "aws_iam_role" "bedrock_iam_role"{
    name = "ia-test-bedrock-iam-role"

    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "bedrock.amazonaws.com"
            }
        }
        ]
    })

}

resource "aws_iam_policy" "bedrock_iam_policy"{
    name = "ia-test-bedrock-iam-policy"
    description = "Politica personalizada para bedrock"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                "Effect": "Allow",
                "Action": [
                    "s3:GetObject",
                    "s3:ListBucket"
                ],
                "Resource":[
                    "${var.processed_bucket_arn}",
                    "${var.processed_bucket_arn}/*"
                ]
            },
            {
                "Effect": "Allow",
                "Action":[
                    "bedrock:InvokeModel"
                ],
                "Resource":[
                    "arn:aws:bedrock:us-east-2::foundation-model/amazon.titan-embed-text-v2:0"
                ]
            },
            {
                "Effect": "Allow",
                "Action": [
                    "aoss:APIAccessAll"
                ],
                "Resource": [
                    "${var.opensearch_collection_arn}"
                ]
            }
        ]
    })

}

resource "aws_iam_role_policy_attachment" "bedrock_iam_role_policy_attachment"{
    role = aws_iam_role.bedrock_iam_role.name
    policy_arn = aws_iam_policy.bedrock_iam_policy.arn

}

/* Bedrock agentcore IAM role  -------------------------------------------------------------------------------*/
resource "aws_iam_role" "bedrock_agentcore_role" {
    name = "bedrock_agentcore_role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "bedrock.amazonaws.com"
                }
            }
        ]
    })
}

resource "aws_iam_policy" "bedrock_agentcore_policy"{
    name = "bedrock-agentcore-policy"
    description = "Politca personalizada para el agente de bedrock"

    policy = jsonencode({
        Version =  "2012-10-17"
        Statement = [
            {
                "Effect": "Allow",
                "Action": [
                    "bedrock:Retrieve",
                    "bedrock:RetrieveAndGenerate"
                ],
                "Resource": [
                    "${var.knowledge_base_arn}"
                ]
            },
            {
                "Effect": "Allow",
                "Action": [
                    "bedrock:InvokeModel"
                ],
                "Resource": [
                    "arn:aws:bedrock:us-east-2::foundation-model/amazon.nova-pro-v1:0"
                ]
            }
        ]

    })
}

resource "aws_iam_role_policy_attachment" "bedrock_agent_policy_attachment" {
    role = aws_iam_role.bedrock_agentcore_role.name
    policy_arn = aws_iam_policy.bedrock_agentcore_policy.arn
}