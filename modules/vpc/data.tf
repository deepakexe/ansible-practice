#Fetch availablity zones
data "aws_availability_zones" "available" {
  state = "available"
}

#Fetch the VPC ID
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_conf.existing_vpc_name] 
  }
}


#Fetch the app subnets
data "aws_subnets" "private_app_subnets" {
  filter {
    name   = "tag:Name"
    values = var.vpc_conf.existing_private_app_subnet_names
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}
