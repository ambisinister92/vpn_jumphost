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
