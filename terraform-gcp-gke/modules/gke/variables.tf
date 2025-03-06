variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region to deploy resources"
  type        = string
}

variable "zones" {
  description = "The GCP zones to deploy resources"
  type        = list(string)
}

variable "gke_name" {
  description = "Name of the GKE cluster"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "The IDs of the subnets"
  type        = list(string)
}

variable "master_ipv4_cidr" {
  description = "CIDR range for the GKE master"
  type        = string
}

variable "node_machine_type" {
  description = "Machine type for GKE nodes"
  type        = string
}

variable "disk_size_gb" {
  description = "Disk size for GKE nodes in GB"
  type        = number
}

variable "min_node_count" {
  description = "Minimum number of nodes in the node pool"
  type        = number
}

variable "max_node_count" {
  description = "Maximum number of nodes in the node pool"
  type        = number
}

variable "cluster_ipv4_cidr" {
  description = "CIDR range for GKE pods"
  type        = string
}

variable "services_ipv4_cidr" {
  description = "CIDR range for GKE services"
  type        = string
}

variable "min_cpu" {
  description = "Minimum CPU for GKE autoprovisioning"
  type        = number
}

variable "max_cpu" {
  description = "Maximum CPU for GKE autoprovisioning"
  type        = number
}

variable "min_memory" {
  description = "Minimum memory for GKE autoprovisioning in GB"
  type        = number
}

variable "max_memory" {
  description = "Maximum memory for GKE autoprovisioning in GB"
  type        = number
}

variable "enable_private_nodes" {
  description = "Enable private nodes for GKE"
  type        = bool
  default     = true
}

variable "enable_private_endpoint" {
  description = "Enable private endpoint for GKE"
  type        = bool
  default     = false
}

variable "master_authorized_networks" {
  description = "List of CIDR blocks to allow access to the Kubernetes master"
  type        = list(object({ cidr_block = string, display_name = string }))
  default     = []
}
