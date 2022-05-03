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


module "openvpn" {
  source            = "github.com/tieto-cem/terraform-aws-openvpn?ref=v1.3.0"
  name              = "OpenVPN"
  ami               = var.openvpn.ami
  region            = var.region
  instance_type     = var.openvpn.instance_type
  key_name          = var.aws_key_name
  vpc_id            = module.vpc.vpc_id
  subnet_id         = module.vpc.public_subnets[0]
  cidr              = var.cidrList.vpc.cidr
  source_dest_check = false
  allow_nat         = false
  allow_ssh_port    = true
  ssh_cidr          = ["0.0.0.0/0"]
  user_data         = ""
  tags = {
    Name = "OpenVPN"
  }
  volume_tags = {
    Name = "OpenVPN"
  }
}
