output "build_repo_url" {
  value = aws_codecommit_repository.deployment_repo.clone_url_http
}