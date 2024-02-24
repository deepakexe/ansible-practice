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

module "vpc" {
  source   = "../modules/vpc"
  vpc_conf = var.vpc_conf
}

module "cloudhsm" {
  source                   = "../modules/cloudhsm"
  cloudhsm_cluster_subnets = module.vpc.app_subnets
  cloudhsm_conf            = var.cloudhsm_conf
  vpc_cidr                 = module.vpc.cidr_block
}

module "ec2" {
  depends_on    = [module.cloudhsm]
  source        = "../modules/ec2"
  ec2_subnet_id = module.vpc.app_subnets[0]
  vpc_id        = module.vpc.vpc_id
  ec2_conf      = var.ec2_conf
}



