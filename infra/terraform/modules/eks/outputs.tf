output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}

output "kubeconfig" {
  description = "The kubeconfig file content"
  value       = local_file.kubeconfig.content
}
