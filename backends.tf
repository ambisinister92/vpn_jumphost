terraform {
  backend "s3" {
    bucket         = "opnvpntest-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "test-terraform-state-lock"
  }
}
