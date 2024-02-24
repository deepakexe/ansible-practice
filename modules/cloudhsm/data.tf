#data call to import csr
data "aws_cloudhsm_v2_cluster" "csr" {
  depends_on = [ aws_cloudhsm_v2_hsm.hsm1 ]
  cluster_id = aws_cloudhsm_v2_cluster.main.id
}

