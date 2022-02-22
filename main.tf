terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}


provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}



module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.cidrList.vpc.name
  cidr = var.cidrList.vpc.cidr

  azs             = ["${var.region}a", "${var.region}b"]
  private_subnets = [var.cidrList.private_sub.cidr]
  public_subnets  = [var.cidrList.public_sub.cidr]



  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
