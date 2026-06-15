resource "aws_bedrockagent_knowledge_base" "ia_kb" {
    name = "ia-test-knowledge-base"
    role_arn = var.bedrock_iam_role_arn

    knowledge_base_configuration {
        type = "VECTOR"

        vector_knowledge_base_configuration {
            embedding_model_arn = "arn:aws:bedrock:us-east-2::foundation-model/amazon.titan-embed-text-v2:0"
        }
    }
    storage_configuration {
        type = "OPENSEARCH_SERVERLESS"

        opensearch_serverless_configuration {
            collection_arn = var.opensearch_collection_arn
            vector_index_name = "bedrock-knowledge-base-default-index"

            field_mapping {
                vector_field = "bedrock-knowledge-base-default-vector"

                text_field = "AMAZON_BEDROCK_TEXT_CHUNK"

                metadata_field = "AMAZON_BEDROCK_METADATA"
            }
        }
    }
}

resource "aws_bedrockagent_data_source" "s3_data_source" {
    knowledge_base_id = aws_bedrockagent_knowledge_base.ia_kb.id
    name              = "ia-test-s3-data-source"
    
    data_source_configuration {
      type = "S3"
      s3_configuration {
        bucket_arn = var.processed_bucket_arn 
      }
    }

    vector_ingestion_configuration {
        chunking_configuration {
           chunking_strategy = "FIXED_SIZE"

           fixed_size_chunking_configuration {
                max_tokens = 400
                overlap_percentage = 20 
           }
        }
    }

}