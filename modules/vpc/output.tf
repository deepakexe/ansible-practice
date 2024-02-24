output "vpc_id" {
    value = data.aws_vpc.selected.id
  
}

output "app_subnets" {
    value = data.aws_subnets.private_app_subnets.ids
}

output "cidr_block" {
    value = data.aws_vpc.selected.cidr_block
}