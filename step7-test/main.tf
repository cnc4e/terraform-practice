module "network" {
  source = "./network"

  pj          = var.pj
  vpc-cidr    = var.vpc-cidr
  subnet-cidr = var.subnet-cidr
}

module "compute" {
  source = "./compute"

  pj                = var.pj
  app               = "front"
  type              = var.type
  vpc-id            = module.network.vpc-id
  subnet-id         = module.network.subnet-id
  allow-access-cidr = var.allow-access-cidr
  allow-tcp-ports   = var.allow-tcp-ports
}

module "backend" {
  source = "./compute"

  pj                = var.pj
  app               = "back"
  type              = var.type
  vpc-id            = module.network.vpc-id
  subnet-id         = module.network.subnet-id
  allow-access-cidr = var.allow-access-cidr
  allow-tcp-ports   = var.allow-tcp-ports
}
