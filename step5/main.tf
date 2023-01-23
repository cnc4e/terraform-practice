module "network1" {
  source = "./network"

  vpc-cidr     = var.vpc-cidr
  subnet-cidrs = var.subnet-cidrs
}

module "network2" {
  source = "./network"

  vpc-cidr     = var.vpc-cidr
  subnet-cidrs = var.subnet-cidrs
}

module "compute" {
  source = "./compute"

  type      = var.type
  subnet-id = module.network1.subnet-ids[0]
}