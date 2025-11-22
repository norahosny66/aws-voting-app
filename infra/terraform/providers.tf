terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # Pick a version compatible with all modules, e.g., >= 6.20
      version = ">= 6.20.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
    tls = {
      source = "hashicorp/tls"
      version = "~> 4.1"
    }
    time = {
      source = "hashicorp/time"
      version = "~> 0.13"
    }
    null = {
      source = "hashicorp/null"
      version = "~> 3.2"
    }
    cloudinit = {
      source = "hashicorp/cloudinit"
      version = "~> 2.3"
    }
  }
}
