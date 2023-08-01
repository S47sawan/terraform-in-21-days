output "vpc_id" {
  value = aws_vpc.env_vpc.id
}
output "public_subnet_id" {
  value = aws_subnet.pub_sub[*].id
}
output "private_subnet_id" {
  value = aws_subnet.prt_sub[*].id
}
output "vpc_cidr" {
  value = var.vpc_cidr
}
