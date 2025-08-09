/*output "eks_cluster_name" {
  value = module.eks.cluster_id
}
output "ecr_repo_url" {
  value = aws_ecr_repository.webapp_game.repository_url
}*/
output "jenkins_public_ip" {
  description = "Public IP of Jenkins server"
  value       = aws_instance.jenkins_server.public_ip
}