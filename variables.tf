variable "access_key" {}
variable "secret_key" {}


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
