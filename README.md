terraform-openvpn-AWS-jumphost



This Terraform config will let you setup your own secure VPN jumphost with private subnet with 2 Amazon-linux instances behind in just a few seconds.
It uses AWS-VPC module from [This](https://github.com/terraform-aws-modules/terraform-aws-vpc) to create network infrastructure, openvpn module from [This](https://github.com/tieto-cem/terraform-aws-openvpn) to create openvpn linux instance and security group for it, for openvpn installation and configuration it uses script from [This](https://github.com/angristan/openvpn-install).

##Prerequirements

To run this config you need:

- installed OpenVPN
- AWS account
- S3 bucket and Dynamo DB table to backend setup
- EC2 pem-key

## Usage

Type in console:

```bash
terraform init
terraform aplly
sudo openvpn --config ./ovpn_config/client.ovpn --daemon
```
