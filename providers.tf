terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"

  default_tags {
    tags = {
          Cuenta             = "ION-Seguridad"  
          Ambiente            = "Dev"
          CentroCostos = "TRANSFORMACION Y TECNOLOGIA"
          Responsable        = "franco.sanchez"
          Poryecto           = "IA-RAG"
          Proveedor           = "ION"
          AreaNegocio        = "DESARROLLO"
      }
    }
  }
