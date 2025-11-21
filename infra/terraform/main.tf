module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  vpc_cidr     = "10.0.0.0/16"
  public_subnets_cidr = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]
  private_subnets_cidr = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24"
  ]
}

module "eks" {
  source = "./modules/eks"

  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  public_subnets  = module.vpc.public_subnets
  aws_region      = var.aws_region
}

module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
  repositories = ["vote", "result", "worker", "seed-data"]
}

output "kubeconfig" {
  description = "The kubeconfig file content"
  value       = module.eks.kubeconfig
  sensitive   = true
}

output "ecr_repositories" {
  description = "Map of ECR repository URLs"
  value       = module.ecr.repository_urls
}

output "public_subnets" {
  value = module.vpc.public_subnets
}
