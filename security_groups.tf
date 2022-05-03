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
