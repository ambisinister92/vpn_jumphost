terraform {

  backend "s3" {
    bucket         = "opnvpntest-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "test-terraform-state-lock"
  }

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


resource "aws_security_group" "private_network_sg" {

  name = "private_network_sg"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidrList.public_sub.cidr]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = module.vpc.vpc_id

  tags = {
    Name = "private_network_sg"
  }

}

resource "aws_instance" "worker_nodez" {

  count = var.worker_node.nodes_count

  ami           = var.worker_node.ami
  instance_type = var.worker_node.instance_type
  key_name      = var.aws_key_name
  subnet_id     = module.vpc.private_subnets[0]

  vpc_security_group_ids = [aws_security_group.private_network_sg.id]

  tags = {
    Name = "worker_node ${count.index + 1}"
  }

}



resource "null_resource" "openvpn_provisioner" {
  triggers = {
    public_ip = module.openvpn.public_ip
  }
  connection {
    host        = module.openvpn.public_ip
    agent       = true
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.aws_key_path)
  }


  provisioner "remote-exec" {
    inline = [
      "curl -O https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh",
      "chmod +x /home/ubuntu/openvpn-install.sh",
      "sudo AUTO_INSTALL=y ./openvpn-install.sh"
    ]
  }
}


resource "null_resource" "client_conf" {
  triggers = {
    id = null_resource.openvpn_provisioner.id
  }


  provisioner "local-exec" {
    command = "yes yes | ssh-keyscan -t rsa,ed25519 ${module.openvpn.public_ip} >> ~/.ssh/known_hosts; mkdir ovpn_config; scp -i ${var.aws_key_path} ubuntu@${module.openvpn.public_ip}:/home/ubuntu/client.ovpn ./ovpn_config; echo \"Connect to VPN:\nsudo openvpn --config ./ovpn_config/client.ovpn --daemon\nConnect to openvpn server:\nssh-add ${var.aws_key_path}\nssh -Ai ${var.aws_key_path} ubuntu@10.8.0.1\nList of private sub nodes:\n%{for ip in aws_instance.worker_nodez.*.private_ip}server ${ip}\n%{endfor}\">>./ovpn_config/info.txt; cat ./ovpn_config/info.txt"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "if ls|grep ovpn_config; then  rm -rf ./ovpn_config; fi"
  }
}
