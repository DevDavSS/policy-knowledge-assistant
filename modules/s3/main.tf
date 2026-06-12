resource "aws_s3_bucket" "ia_test_raw_documents" {
    bucket = "ia-test-raw-documents"
    
}

resource "aws_s3_bucket" "ia_test_processed_documents" {
    bucket = "ia-test-processed-documents"
    
}
