variable "access_key" {}
variable "secret_key" {}

variable "aws_key_name" {}
variable "aws_key_path" {}


variable "region" {
  default = "us-east-2"
}

variable "cidrList" {
  default = {
    vpc         = { name = "test-vpc", cidr = "10.14.0.0/16" }
    public_sub  = { name = "test-sub-public", cidr = "10.14.1.0/24" }
    private_sub = { name = "test-sub-private", cidr = "10.14.2.0/24" }
  }
}


variable "openvpn" {
  default = {
    ami           = "ami-0fb653ca2d3203ac1"
    instance_type = "t2.micro"

  }
}

variable "worker_node" {
  default = {
    nodes_count   = 2
    ami           = "ami-0c7478fd229861c57"
    instance_type = "t2.micro"
  }
}
