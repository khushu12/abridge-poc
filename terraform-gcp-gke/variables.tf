# Credentials
variable "credentials_file" {
  description = "Path to the GCP service account JSON key file"
  type        = string
}

# General variables
variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region to deploy resources"
  type        = string
  default     = "us-central1"
}

variable "zones" {
  description = "The GCP zones to deploy resources"
  type        = list(string)
  default     = ["us-central1-a", "us-central1-b"]
}

# VPC variables
variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "gke-vpc"
}

variable "vpc_cidr" {
  description = "CIDR range for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_name" {
  description = "Name of the public subnet"
  type        = string
  default     = "public-subnet"
}

variable "public_subnet_cidr" {
  description = "CIDR range for the public subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "private_subnet_1_name" {
  description = "Name of the first private subnet"
  type        = string
  default     = "private-subnet-1"
}

variable "private_subnet_1_cidr" {
  description = "CIDR range for the first private subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_2_name" {
  description = "Name of the second private subnet"
  type        = string
  default     = "private-subnet-2"
}

variable "private_subnet_2_cidr" {
  description = "CIDR range for the second private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "nat_name" {
  description = "Name of the Cloud NAT"
  type        = string
  default     = "gke-nat"
}

variable "nat_router_name" {
  description = "Name of the Cloud Router for NAT"
  type        = string
  default     = "gke-nat-router"
}

variable "create_internet_gateway" {
  description = "Whether to create an internet gateway for the public subnet"
  type        = bool
  default     = true
}

# GKE variables
variable "gke_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "gke-cluster"
}

variable "master_ipv4_cidr" {
  description = "CIDR range for the GKE master"
  type        = string
  default     = "172.16.0.0/28"
}

variable "node_machine_type" {
  description = "Machine type for GKE nodes"
  type        = string
  default     = "e2-standard-4"
}

variable "disk_size_gb" {
  description = "Disk size for GKE nodes in GB"
  type        = number
  default     = 200
}

variable "min_node_count" {
  description = "Minimum number of nodes in the node pool"
  type        = number
  default     = 2
}

variable "max_node_count" {
  description = "Maximum number of nodes in the node pool"
  type        = number
  default     = 25
}

variable "cluster_ipv4_cidr" {
  description = "CIDR range for GKE pods"
  type        = string
  default     = "/16"
}

variable "services_ipv4_cidr" {
  description = "CIDR range for GKE services"
  type        = string
  default     = "/16"
}

variable "min_cpu" {
  description = "Minimum CPU for GKE autoprovisioning"
  type        = number
  default     = 1
}

variable "max_cpu" {
  description = "Maximum CPU for GKE autoprovisioning"
  type        = number
  default     = 200
}

variable "min_memory" {
  description = "Minimum memory for GKE autoprovisioning in GB"
  type        = number
  default     = 1
}

variable "max_memory" {
  description = "Maximum memory for GKE autoprovisioning in GB"
  type        = number
  default     = 2000
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
