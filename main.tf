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
    Terraform = "true"
  }
}


resource "aws_route53_zone" "test_r53z0ne" {
  name = var.r53domain_name

  vpc {
    vpc_id = module.vpc.vpc_id
  }

  tags = {
    Name = "test_r53z0ne"
  }
}


module "openvpn" {
  source = "anugnes/openvpn/aws"

  ami               = var.openvpn.ami
  domain            = var.r53domain_name
  ebs_region        = var.region
  ebs_size          = var.openvpn.ebs_size
  instance_type     = var.openvpn.instance_type
  key_name          = var.aws_key_name
  public_subnet_ids = module.vpc.public_subnets
  route_zone_id     = aws_route53_zone.test_r53z0ne.id
  vpc_cidr          = var.cidrList.vpc.cidr
  vpc_id            = module.vpc.vpc_id
}
