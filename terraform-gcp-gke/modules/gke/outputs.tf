output "cluster_id" {
  description = "The ID of the GKE cluster"
  value       = google_container_cluster.gke.id
}

output "cluster_name" {
  description = "The name of the GKE cluster"
  value       = google_container_cluster.gke.name
}

output "cluster_endpoint" {
  description = "The endpoint for the GKE cluster"
  value       = google_container_cluster.gke.endpoint
}

output "kubeconfig" {
  description = "Kubeconfig for the GKE cluster"
  value       = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${google_container_cluster.gke.master_auth.0.cluster_ca_certificate}
    server: https://${google_container_cluster.gke.endpoint}
  name: ${google_container_cluster.gke.name}
contexts:
- context:
    cluster: ${google_container_cluster.gke.name}
    user: ${google_container_cluster.gke.name}
  name: ${google_container_cluster.gke.name}
current-context: ${google_container_cluster.gke.name}
kind: Config
preferences: {}
users:
- name: ${google_container_cluster.gke.name}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: gcloud
      args:
      - "container"
      - "clusters"
      - "get-credentials"
      - "${google_container_cluster.gke.name}"
      - "--region"
      - "${var.region}"
      - "--project"
      - "${var.project_id}"
KUBECONFIG
}
