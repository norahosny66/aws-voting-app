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
module "iam" {
  source = "./modules/iam"
  cluster_oidc_issuer_url = module.eks.oidc_provider_url
  # ... other args ...
  cluster_name        = module.eks.cluster_name
  
  oidc_provider_arn   = module.eks.oidc_provider_arn

  # ... any others required ...
}

resource "kubernetes_service_account" "alb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam.alb_controller_role_arn # Or aws_iam_role.alb_controller.arn if defined in root
    }
  }
  
  depends_on = [ module.eks, module.iam ] # if using modules, or the actual resources
}


resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.7.1" # Or latest compatible with your EKS/K8s version

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }
  set {
    name  = "region"
    value = var.aws_region
  }
  set {
    name  = "vpcId"
    value = module.vpc.vpc_id
  }
  set {
    name  = "serviceAccount.create"
    value = false
  }
  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.alb_controller.metadata[0].name
  }

  depends_on = [
    kubernetes_service_account.alb_controller
  ]
}

data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
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

output "github_actions_role_arn" {
  value = module.iam.github_actions_role_arn
}
