#!/bin/bash
sudo apt update -y
sudo apt install openvpn easy-rsa -y

sudo mv openvpn.conf /etc/openvpn/

export EASYRSA_BATCH=1

make-cadir openvpn-ca
cd openvpn-ca

./easyrsa init-pki
./easyrsa build-ca nopass
./easyrsa gen-req vpnserver nopass
./easyrsa gen-dh
./easyrsa gen-req client nopass
openvpn --genkey --secret ta.key

sudo cp ~/openvpn-ca/pki/private/vpnserver.key  /etc/openvpn/
sudo cp ~/openvpn-ca/ta.key  /etc/openvpn/
sudo cp ~/openvpn-ca/pki/dh.pem  /etc/openvpn/
sudo cp ~/openvpn-ca/pki/ca.crt  /etc/openvpn/

./easyrsa sign-req server vpnserver
sudo cp pki/issued/vpnserver.crt /etc/openvpn/
./easyrsa sign-req client client


#sudo openvpn --genkey --secret /etc/openvpn/ovpn.key
#sudo cp /etc/openvpn/ovpn.key  ~/ && sudo chmod 777 ~/ovpn.key

#sudo modprobe iptable_nat

sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -I FORWARD -i tun0 -o eth0 -s 10.8.0.0/24 -d 10.14.1.0/24 -m conntrack --ctstate NEW -j ACCEPT
sudo iptables -I FORWARD -i tun0 -o eth1 -s 10.8.0.0/24 -m conntrack --ctstate NEW -j ACCEPT
sudo iptables -I FORWARD -i eth0 -o eth1 -s 10.14.1.0/24 -m conntrack --ctstate NEW -j ACCEPT
sudo iptables -I FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
sudo iptables -t nat -I POSTROUTING -o eth1 -s 10.8.0.0/24 -j MASQUERADE
sudo iptables -t nat -I POSTROUTING -o eth1 -s 10.14.1.0/24 -j MASQUERADE
sudo openvpn --genkey --secret /etc/openvpn/ovpn.key
sudo sudo /sbin/iptables-save

sudo openvpn --config openvpn.conf
