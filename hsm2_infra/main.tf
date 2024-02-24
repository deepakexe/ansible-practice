
#Provider
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.region
}

#data call to fetch the availablity zone
data "aws_availability_zones" "available" {}

#create Hsm instance 2
resource "aws_cloudhsm_v2_hsm" "hsm2" {
  availability_zone  = data.aws_availability_zones.available.names[1]
  cluster_id = var.cluster_id
}




