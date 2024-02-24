#region where all the resources will be created
region = "eu-west-2" 

#VPC configuration
vpc_conf = {                                                                                                   #VPC and related resources configuration
  existing_vpc_name                 = "poc-vpc"                                                                #Replace with the VPC name in which you want to create the CLoudHSM cluster
  existing_private_app_subnet_names = ["poc-private-subnet-A", "poc-private-subnet-B", "poc-private-subnet-C"] #replace with the private app subnets of the vpc
}



#cloudhsm infra configuration
cloudhsm_conf = {
  cluster = {
    hsm_type = "hsm1.medium"
    tags = {
      Name = "test_cloudhsm_v2_cluster"
    }
  }
  hsm_instances = 2
  cloudhsm_sg = {
    windows_server_ip = "192.168.46.92/32"
    type      = "ingress"
    from_port = 2223
    to_port   = 2225
    protocol  = "tcp"
  }
}

#EC2 configuraions
ec2_conf = {
  instance_type = "t2.micro"
  name          = "test_hsm_client"
  sg = {
    identifier  = "ec2"
    name        = "test_hsm_client_sg2"
    description = "test hsm bastient host sg"


    egress = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  iam_policy_arn            = ["arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM", "arn:aws:iam::aws:policy/AWSCloudHSMFullAccess"]
  iam_role_name             = "test-cloudhsm-access-role"
  iam_instance_profile_name = "test_cloudhsm_ec2_profile"
}

#cloudHSM Cluster Id 
cluster_id = ""  #replace with the cloudHSM cluster id once you have activated it 


