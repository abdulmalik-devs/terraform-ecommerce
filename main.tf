module "vpc" {
  source                       = "./modules/vpc"

  vpc_name                     = "vpc_prod"
}

module "ec2_client_admin" {
  source                       = "./modules/ec2_public"

  instance_name                = "client-admin"
  security_group_id            = [module.security_group.sg-instance]
  subnet_id                    = module.vpc.public_subnet_1a
}

module "ec2_backend" {
  source                       = "./modules/ec2_private"

  instance_name                = "backend"
  security_group_id            = [module.security_group.sg-instance]
  subnet_id                    = module.vpc.private_subnet_1c
}

module "ec2_database" {
  source                       = "./modules/ec2_private"

  instance_name                = "database"
  security_group_id            = [module.security_group.sg-instance]
  subnet_id                    = module.vpc.private_subnet_1c
}

module "security_group" {
  source                       = "./modules/sg"

  sg_name_prefix               = "instance-sg"
  vpc_id                       = module.vpc.vpc-id
}
