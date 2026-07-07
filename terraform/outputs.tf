output "environment" {
  value = terraform.workspace
}

output "vpc_id" {
  value = module.infrastructure.vpc_id
}

output "ec2_public_ip" {
  value = module.infrastructure.ec2_public_ip
}