terraform {
  backend "s3" {
    bucket         = "stg-terraform-state-backend-xxx"
    key            = "terraform.tfstate"
    region         = "ap-northeast-1"
    encrypt        = true
    # dynamodb_table = "xxx-test-terraform"
  }
}