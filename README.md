# terraform-openvpn-AWS-jumphost


This Terraform config will let you setup your own secure VPN jumphost with private subnet with 2 Amazon-linux instances behind in just a few seconds.
It uses AWS-VPC module from [This](https://github.com/terraform-aws-modules/terraform-aws-vpc) to create network infrastructure, openvpn module from [This](https://github.com/tieto-cem/terraform-aws-openvpn) to create openvpn linux instance and security group for it, for openvpn installation and configuration it uses script from [This](https://github.com/angristan/openvpn-install).

## Prerequirements

To run this config you need:

- installed OpenVPN
- AWS account
- S3 bucket and Dynamo DB table to configure state lock
- AWS private key to access nodes

## Usage

Firstly configure state lock in backends.tf. Then configure variables in variables.tf
Then type in console:

```bash
terraform init
terraform aplly
```
After that terraform creates VPC with public and private subnet. In public subnet would be created Ubuntu based jumphost with  running OpenVPN server and CA. In private subnet would be created 2 Amazon Linux 2 based instances. On your local machine would be created ovpn_config directory with client configuration file (client.ovpn) and infofile that contains virtual IP of your OpenVPN instance and IPs of private instances.

To connect to VPN type:

```bash
sudo openvpn --config ./ovpn_config/client.ovpn --daemon
```
