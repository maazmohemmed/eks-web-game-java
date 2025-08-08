module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "webapp-game-eks"
  cluster_version = "1.21"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id
}
