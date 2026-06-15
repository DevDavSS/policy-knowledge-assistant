/*Politica de cifrado de datos (como se cifraran)*/
resource "aws_opensearchserverless_security_policy" "encryption" {
  name = "ia-encryption-policy"

  type = "encryption"

  policy = jsonencode({
    Rules = [
      {
        Resource = [
          "collection/ia-vector-store"
        ]
        ResourceType = "collection"
      }
    ]

    AWSOwnedKey = true
  })
}

/*Política de conexion a la base vectorial*/
resource "aws_opensearchserverless_security_policy" "network" {
  name = "ia-network-policy"

  type = "network"

  policy = jsonencode([
    {
      Rules = [
        {
          Resource = [
            "collection/ia-vector-store"
          ]
          ResourceType = "collection"
        }
      ]

      AllowFromPublic = true  /*Not VPC encpoints yet*/
    }
  ])
}

/* Permission for bedrock allowing entering to vectore store*/
resource "aws_opensearchserverless_access_policy" "bedrock_vectorstore_access" {
  name = "ia-bedrock-access-policy"

  type = "data"

    policy = jsonencode([
        {
            Rules = [
                {
                    ResourceType = "collection",
                    Resource = [
                        "collection/ia-vector-store"
                    ],
                    Permission = [
                        "aoss:CreateCollectionItems",
                        "aoss:UpdateCollectionItems",
                        "aoss:DescribeCollectionItems"
                    ]
                },
                {
                    ResourceType = "index",
                    Resource = [
                        "index/ia-vector-store/*"
                    ],
                    Permission = [
                        "aoss:CreateIndex",
                        "aoss:DeleteIndex",
                        "aoss:UpdateIndex",
                        "aoss:DescribeIndex",
                        "aoss:ReadDocument",
                        "aoss:WriteDocument"
                    ]
                }
            ],
            Principal = [
                var.bedrock_role_arn
            ]
        }
    ])
}

/* Vectore Store creation */
resource "aws_opensearchserverless_collection" "vector_store" {

  name = "ia-vector-store"

  type = "VECTORSEARCH"

  depends_on = [
    aws_opensearchserverless_security_policy.encryption,
    aws_opensearchserverless_security_policy.network
  ]
}

