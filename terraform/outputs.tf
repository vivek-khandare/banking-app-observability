output "jenkins_public_ip" {
  description = "Public IP of Jenkins Server"
  value       = aws_instance.jenkins.public_ip
}

output "k3s_server_public_ip" {
  description = "Public IP of K3s Server"
  value       = aws_instance.k3s_server.public_ip
}

output "k3s_worker_public_ip" {
  description = "Public IP of K3s Worker"
  value       = aws_instance.k3s_worker.public_ip
}
