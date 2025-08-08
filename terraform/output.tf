output "eks_cluster_name" {
  value = module.eks.cluster_id
}
output "ecr_repo_url" {
  value = aws_ecr_repository.webapp_game.repository_url
}
