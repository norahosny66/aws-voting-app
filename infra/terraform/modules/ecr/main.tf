resource "aws_ecr_repository" "app_repos" {
  for_each = toset(var.repositories)
  name     = "${var.project_name}-${each.key}"

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

output "repository_urls" {
  description = "Map of ECR repository URLs"
  value = {
    for repo in aws_ecr_repository.app_repos : repo.name => repo.repository_url
  }
}
