/*Package the lambda function role*/
data "archive_file" "lambda_function_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_function"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "document_processing_lambda"{
    function_name = "document-processing-lambda"
    role = var.lambda_iam_role_arn
    runtime = "python3.10"
    handler = "lambda_function.lambda_handler"
    code_sha256   = data.archive_file.lambda_function_zip.output_base64sha256
    
    filename = data.archive_file.lambda_function_zip.output_path

    environment {
      variables = {
        RAW_BUCKET_NAME = var.s3_raw_bucket_name
        PROCESSED_BUCKET_NAME = var.s3_processed_bucket_name
      }
    }

}