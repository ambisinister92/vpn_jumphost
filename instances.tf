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
