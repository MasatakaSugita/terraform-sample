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

module "elb" {
  source = "./module/elb"

  app_name = var.app_name

  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  zone              = var.zone
  domain            = var.domain
  acm_id            = module.acm.acm_id
}

module "ecs_cluster" {
  source   = "./module/ecs_cluster"
  app_name = var.app_name
}

module "ecr" {
  source = "./module/ecr"
  app_name = var.app_name
}

module "iam" {
  source   = "./module/iam"
  app_name = var.app_name
}

module "ecs_app" {
  source = "./module/ecs_app"

  app_name = var.app_name
  cluster_name = module.ecs_cluster.cluster_name
  vpc_id                      = module.network.vpc_id
  public_subnet_ids           = module.network.public_subnet_ids
  https_listener_arn          = module.elb.https_listener_arn
  iam_role_task_execution_arn = module.iam.iam_role_task_execution_arn
  retention_in_days = 7
}