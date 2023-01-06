module "network" {
  source   = "./module/network"
  app_name = var.app_name
  vpc_cidr = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs      = var.azs
}

module "acm" {
  source   = "./module/acm"
  app_name = var.app_name
  zone     = var.zone
  domain   = var.domain
}