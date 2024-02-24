#CloudHSM cluster
resource "aws_cloudhsm_v2_cluster" "main" {
  hsm_type   = var.cloudhsm_conf.cluster.hsm_type
  subnet_ids = var.cloudhsm_cluster_subnets[*]

  tags = {
    Name = var.cloudhsm_conf.cluster.tags.Name
  }
}

#adding inbound rule to the cloudhsm_sg for ec2
resource "aws_security_group_rule" "allow_ec2" {
  security_group_id = aws_cloudhsm_v2_cluster.main.security_group_id
  type              = var.cloudhsm_conf.cloudhsm_sg.type
  from_port         = var.cloudhsm_conf.cloudhsm_sg.from_port
  to_port           = var.cloudhsm_conf.cloudhsm_sg.to_port
  protocol          = var.cloudhsm_conf.cloudhsm_sg.protocol
  cidr_blocks       = ["${var.vpc_cidr}"]  
}

#adding inbound rule to the cloudhsm_sg for windows server
resource "aws_security_group_rule" "allow_windows_server" {
  security_group_id = aws_cloudhsm_v2_cluster.main.security_group_id
  type              = var.cloudhsm_conf.cloudhsm_sg.type
  from_port         = var.cloudhsm_conf.cloudhsm_sg.from_port
  to_port           = var.cloudhsm_conf.cloudhsm_sg.to_port
  protocol          = var.cloudhsm_conf.cloudhsm_sg.protocol
  cidr_blocks       = ["${var.cloudhsm_conf.cloudhsm_sg.windows_server_ip}"]  
}

#HSM instance 1
resource "aws_cloudhsm_v2_hsm" "hsm1" {
  subnet_id  = var.cloudhsm_cluster_subnets[0]
  cluster_id = aws_cloudhsm_v2_cluster.main.cluster_id
}


#Import csr to a local file 
resource "local_file" "get_csr" {
  depends_on = [ aws_cloudhsm_v2_hsm.hsm1 ]
  content  = data.aws_cloudhsm_v2_cluster.csr.cluster_certificates.0.cluster_csr
  filename = "${aws_cloudhsm_v2_cluster.main.id}_ClusterCsr.csr"
}

#private key resource
resource "null_resource" "private_key" {
  depends_on = [local_file.get_csr]

  # local exec to create a private key
  provisioner "local-exec" {
    command = "openssl genrsa -aes256 -passout pass:pass123 -out customerCA.key 2048"
  }
}


#self-signed certificate
resource "null_resource" "self_signed_certificate" {
  depends_on = [null_resource.private_key]

  # local exec to create a self-signed certificate
  provisioner "local-exec" {
    command = "openssl req -new -x509 -days 3652 -key customerCA.key -out customerCA.crt -passin pass:pass123 -subj '/C=US/ST=State/L=City/O=Organization/CN=CommonName'"
  }
}


# generate the signed HSM certificate
resource "null_resource" "generate_certificate" {
  depends_on = [local_file.get_csr, null_resource.self_signed_certificate]

  # local exec to sign the cluster CSR
  provisioner "local-exec" {
    command = "openssl x509 -req -days 3652 -in ${aws_cloudhsm_v2_cluster.main.id}_ClusterCsr.csr -CA customerCA.crt -CAkey customerCA.key -CAcreateserial -out '${aws_cloudhsm_v2_cluster.main.id}_CustomerHsmCertificate.crt' -passin pass:pass123"
  }
}

#initialize cluster
resource "null_resource" "initialize_cluster" {
  depends_on = [null_resource.generate_certificate]

  provisioner "local-exec" {
    command = "aws cloudhsmv2 initialize-cluster --cluster-id ${aws_cloudhsm_v2_cluster.main.id} --signed-cert file://'${aws_cloudhsm_v2_cluster.main.id}_CustomerHsmCertificate.crt' --trust-anchor file://customerCA.crt"
  }
}

