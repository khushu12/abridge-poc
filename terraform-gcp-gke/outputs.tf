output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.network.vpc_id
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = module.network.public_subnet_id
}

output "private_subnet_1_id" {
  description = "The ID of the first private subnet"
  value       = module.network.private_subnet_1_id
}

output "private_subnet_2_id" {
  description = "The ID of the second private subnet"
  value       = module.network.private_subnet_2_id
}

output "gke_id" {
  description = "The ID of the GKE cluster"
  value       = module.gke.cluster_id
}

output "gke_endpoint" {
  description = "The endpoint for the GKE cluster"
  value       = module.gke.cluster_endpoint
}

output "kubeconfig" {
  description = "Kubeconfig for the GKE cluster"
  value       = module.gke.kubeconfig
  sensitive   = true
}
