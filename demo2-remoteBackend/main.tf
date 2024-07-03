
# initioally, use local backend only... no remote
# terraform {
#   required_providers {
#     aws = {
#         source = "hashicorp/aws"
#         version = "~> 5.0"
#     }
#   }
# }


#remote backend 
terraform {

  backend "s3" {
    bucket = "tf-state-rhustish"
    key = "tf-infra/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform_locks"
    encrypt = true
  }

  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}   

resource "aws_s3_bucket" "terraform_state" {
  bucket = "tf-state-rhustish"
  force_destroy = true
}   

resource "aws_s3_bucket_versioning" "tf-state-versioned" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf-state-configured" {   
  bucket = aws_s3_bucket_versioning.tf-state-versioned.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


resource "aws_dynamodb_table" "terraform_locks" {
  name = "tf-state-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}