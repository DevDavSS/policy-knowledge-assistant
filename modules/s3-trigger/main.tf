/* S3 Trigger Permission for Processing Lambda */

resource "aws_lambda_permission" "s3_trigger" {
    statement_id = "AllowExecutionFromS3"
    action       = "lambda:InvokeFunction"
    function_name = var.processing_lambda_name
    principal = "s3.amazonaws.com"
    source_arn = var.raw_bucket_arn
}

resource "aws_s3_bucket_notification" "s3_trigger_notification" {
    bucket = var.raw_bucket_id

    lambda_function {
        lambda_function_arn = var.processing_lambda_arn

        events = [
        "s3:ObjectCreated:*"
        ]
    }
    depends_on = [ 
        aws_lambda_permission.s3_trigger
     ]

}