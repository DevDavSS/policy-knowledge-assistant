module "s3" {
  source = "./modules/s3"
}

module "iam" {
  source = "./modules/iam"

  raw_bucket_arn = module.s3.raw_bucket_arn
  processed_bucket_arn = module.s3.processed_bucket_arn
}

module "lambda" {
  source = "./modules/lambda"
  lambda_iam_role_arn = module.iam.lambda_document_processing_role_arn

  s3_raw_bucket_name = module.s3.raw_bucket_name
  s3_processed_bucket_name = module.s3.processed_bucket_name
}

module "s3-trigger"{
  source = "./modules/s3-trigger"
  
  raw_bucket_id = module.s3.raw_bucket_id
  raw_bucket_arn = module.s3.raw_bucket_arn
  
  processing_lambda_arn = module.lambda.processing_lambda_arn
  processing_lambda_name = module.lambda.processing_lambda_name

}

module "opensearch" {
  source = "./modules/opensearch"
}

module "bedrock_kb" {
  source = "./modules/bedrock-knowledge-base"
}

module "agentcore" {
  source = "./modules/agentcore"
}

module "monitoring" {
  source = "./modules/monitoring"
}