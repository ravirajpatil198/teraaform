module "infrastructure" {
  source        = "./modules/vpc_ec2"
  env           = terraform.workspace
  vpc_cidr      = var.env_config[terraform.workspace].vpc_cidr
  subnet_cidr   = var.env_config[terraform.workspace].subnet_cidr
  instance_type = var.env_config[terraform.workspace].instance_type
}