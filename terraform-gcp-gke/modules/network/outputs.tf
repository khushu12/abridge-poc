output "vpc_id" {
  description = "The ID of the VPC"
  value       = google_compute_network.vpc.id
}

output "vpc_name" {
  description = "The name of the VPC"
  value       = google_compute_network.vpc.name
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = google_compute_subnetwork.public.id
}

output "private_subnet_1_id" {
  description = "The ID of the first private subnet"
  value       = google_compute_subnetwork.private_1.id
}

output "private_subnet_2_id" {
  description = "The ID of the second private subnet"
  value       = google_compute_subnetwork.private_2.id
}
