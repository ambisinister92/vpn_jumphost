terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  prvate_subnet_cidr = var.prvate_subnet_cidr
}

module "ec2" {
  source        = "./modules/ec2"
  amis          = var.amis
  instance_type = var.instance_type
  subnet_ids    = module.vpc.subnet_ids
  sg_ids        = module.vpc.sg_ids
}
