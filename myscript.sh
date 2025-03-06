#!/bin/bash

# Script to set up a GCP Terraform project structure with JSON credentials support
# This will create the directory structure, install dependencies, and initialize the Terraform modules

set -e

echo "Setting up GCP Terraform project structure..."

# Create base directories
mkdir -p terraform-gcp-gke
cd terraform-gcp-gke
mkdir -p modules/network modules/gke scripts outputs

# Create main project files
cat > main.tf << 'EOF'
provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = file(var.credentials_file)
}

provider "google-beta" {
  project     = var.project_id
  region      = var.region
  credentials = file(var.credentials_file)
}

module "network" {
  source = "./modules/network"

  project_id              = var.project_id
  region                  = var.region
  vpc_name                = var.vpc_name
  vpc_cidr                = var.vpc_cidr
  public_subnet_name      = var.public_subnet_name
  public_subnet_cidr      = var.public_subnet_cidr
  private_subnet_1_name   = var.private_subnet_1_name
  private_subnet_1_cidr   = var.private_subnet_1_cidr
  private_subnet_2_name   = var.private_subnet_2_name
  private_subnet_2_cidr   = var.private_subnet_2_cidr
  nat_name                = var.nat_name
  nat_router_name         = var.nat_router_name
  create_internet_gateway = var.create_internet_gateway
}

module "gke" {
  source = "./modules/gke"

  project_id              = var.project_id
  region                  = var.region
  zones                   = var.zones
  gke_name                = var.gke_name
  vpc_id                  = module.network.vpc_id
  subnet_ids              = [module.network.private_subnet_1_id, module.network.private_subnet_2_id]
  master_ipv4_cidr        = var.master_ipv4_cidr
  node_machine_type       = var.node_machine_type
  disk_size_gb            = var.disk_size_gb
  min_node_count          = var.min_node_count
  max_node_count          = var.max_node_count
  cluster_ipv4_cidr       = var.cluster_ipv4_cidr
  services_ipv4_cidr      = var.services_ipv4_cidr
  min_cpu                 = var.min_cpu
  max_cpu                 = var.max_cpu
  min_memory              = var.min_memory
  max_memory              = var.max_memory
  enable_private_nodes    = var.enable_private_nodes
  enable_private_endpoint = var.enable_private_endpoint
  master_authorized_networks = var.master_authorized_networks
}
EOF

cat > variables.tf << 'EOF'
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
EOF

cat > outputs.tf << 'EOF'
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
EOF

cat > terraform.tfvars << 'EOF'
# Update these values with your specific configuration
credentials_file         = "./credentials/service-account.json"
project_id              = "your-gcp-project-id"
region                  = "us-central1"
zones                   = ["us-central1-a", "us-central1-b"]
vpc_name                = "gke-vpc"
vpc_cidr                = "10.0.0.0/16"
public_subnet_name      = "public-subnet"
public_subnet_cidr      = "10.0.0.0/24"
private_subnet_1_name   = "private-subnet-1"
private_subnet_1_cidr   = "10.0.1.0/24"
private_subnet_2_name   = "private-subnet-2"
private_subnet_2_cidr   = "10.0.2.0/24"
nat_name                = "gke-nat"
nat_router_name         = "gke-nat-router"
create_internet_gateway = true
gke_name                = "gke-cluster"
master_ipv4_cidr        = "172.16.0.0/28"
node_machine_type       = "e2-standard-4"
disk_size_gb            = 200
min_node_count          = 2
max_node_count          = 25
cluster_ipv4_cidr       = "/16"
services_ipv4_cidr      = "/16"
min_cpu                 = 1
max_cpu                 = 200
min_memory              = 1
max_memory              = 2000
enable_private_nodes    = true
enable_private_endpoint = false
master_authorized_networks = []
EOF

# Create Network Module
cd modules/network
cat > main.tf << 'EOF'
resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  project                 = var.project_id
}

resource "google_compute_subnetwork" "public" {
  name          = var.public_subnet_name
  ip_cidr_range = var.public_subnet_cidr
  network       = google_compute_network.vpc.id
  region        = var.region
  project       = var.project_id
}

resource "google_compute_subnetwork" "private_1" {
  name          = var.private_subnet_1_name
  ip_cidr_range = var.private_subnet_1_cidr
  network       = google_compute_network.vpc.id
  region        = var.region
  project       = var.project_id

  private_ip_google_access = true
}

resource "google_compute_subnetwork" "private_2" {
  name          = var.private_subnet_2_name
  ip_cidr_range = var.private_subnet_2_cidr
  network       = google_compute_network.vpc.id
  region        = var.region
  project       = var.project_id

  private_ip_google_access = true
}

resource "google_compute_router" "router" {
  name    = var.nat_router_name
  region  = var.region
  network = google_compute_network.vpc.id
  project = var.project_id
}

resource "google_compute_router_nat" "nat" {
  name                               = var.nat_name
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  project                            = var.project_id

  subnetwork {
    name                    = google_compute_subnetwork.private_1.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  subnetwork {
    name                    = google_compute_subnetwork.private_2.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

# Firewall rule to allow HTTPS (port 443) traffic to GKE
resource "google_compute_firewall" "allow_https_to_gke" {
  name    = "allow-https-to-gke"
  network = google_compute_network.vpc.id
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  # Target all instances with the gke tag
  target_tags = ["gke"]

  # Allow traffic from anywhere to GKE nodes
  source_ranges = ["0.0.0.0/0"]
}
EOF

cat > variables.tf << 'EOF'
variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region to deploy resources"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR range for the VPC"
  type        = string
}

variable "public_subnet_name" {
  description = "Name of the public subnet"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR range for the public subnet"
  type        = string
}

variable "private_subnet_1_name" {
  description = "Name of the first private subnet"
  type        = string
}

variable "private_subnet_1_cidr" {
  description = "CIDR range for the first private subnet"
  type        = string
}

variable "private_subnet_2_name" {
  description = "Name of the second private subnet"
  type        = string
}

variable "private_subnet_2_cidr" {
  description = "CIDR range for the second private subnet"
  type        = string
}

variable "nat_name" {
  description = "Name of the Cloud NAT"
  type        = string
}

variable "nat_router_name" {
  description = "Name of the Cloud Router for NAT"
  type        = string
}

variable "create_internet_gateway" {
  description = "Whether to create an internet gateway for the public subnet"
  type        = bool
  default     = true
}
EOF

cat > outputs.tf << 'EOF'
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
EOF

# Create GKE Module
cd ../gke
cat > main.tf << 'EOF'
data "google_container_engine_versions" "gke_version" {
  location = var.region
  project  = var.project_id
}

resource "google_service_account" "gke_sa" {
  account_id   = "${var.gke_name}-sa"
  display_name = "GKE Service Account for ${var.gke_name}"
  project      = var.project_id
}

resource "google_project_iam_member" "gke_sa_container_admin" {
  project = var.project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}

resource "google_project_iam_member" "gke_sa_storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}

resource "google_container_cluster" "gke" {
  provider = google-beta

  name     = var.gke_name
  location = var.region
  project  = var.project_id

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.vpc_id
  subnetwork = var.subnet_ids[0]
  
  delete_protection = false
  
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = var.cluster_ipv4_cidr
    services_ipv4_cidr_block = var.services_ipv4_cidr
  }

  private_cluster_config {
    enable_private_nodes    = var.enable_private_nodes
    enable_private_endpoint = var.enable_private_endpoint
    master_ipv4_cidr_block  = var.master_ipv4_cidr
  }

  dynamic "master_authorized_networks_config" {
    for_each = length(var.master_authorized_networks) > 0 ? [1] : []
    content {
      dynamic "cidr_blocks" {
        for_each = var.master_authorized_networks
        content {
          cidr_block   = cidr_blocks.value.cidr_block
          display_name = cidr_blocks.value.display_name
        }
      }
    }
  }

  # Enable Dataplane V2
  datapath_provider = "ADVANCED_DATAPATH"

  # Enable Intra-node Visibility
  enable_intranode_visibility = true

  # Enable Vertical Pod Autoscaling
  vertical_pod_autoscaling {
    enabled = true
  }

  # Enable Managed Prometheus
  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
    managed_prometheus {
      enabled = true
    }
  }

  # Enable logging
  logging_config {
    enable_components = ["SYSTEM_COMPONENTS"]
  }

  # Enable Horizontal Pod Autoscaling
  addons_config {
    horizontal_pod_autoscaling {
      disabled = false
    }
    http_load_balancing {
      disabled = false
    }
    gce_persistent_disk_csi_driver_config {
      enabled = true
    }
  }

  # Enable shielded nodes
  node_config {
    shielded_instance_config {
      enable_secure_boot = true
    }
  }

  # Enable release channel
  release_channel {
    channel = "REGULAR"
  }

  # Enable workload identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Enable autopilot
  cluster_autoscaling {
    enabled = true
    resource_limits {
      resource_type = "cpu"
      minimum       = var.min_cpu
      maximum       = var.max_cpu
    }
    resource_limits {
      resource_type = "memory"
      minimum       = var.min_memory
      maximum       = var.max_memory
    }
    auto_provisioning_defaults {
      service_account = google_service_account.gke_sa.email
      oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
      management {
        auto_repair  = true
        auto_upgrade = true
      }
      disk_size = var.disk_size_gb
      disk_type = "pd-balanced"
    }
  }

  maintenance_policy {
    recurring_window {
      start_time = "2022-01-01T00:00:00Z"
      end_time   = "2022-01-02T00:00:00Z"
      recurrence = "FREQ=WEEKLY;BYDAY=SA,SU"
    }
  }

  # Setting an empty username and password explicitly disables basic auth
  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  # Set the latest available Kubernetes version
  min_master_version = data.google_container_engine_versions.gke_version.latest_master_version
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.gke_name}-node-pool"
  location   = var.region
  cluster    = google_container_cluster.gke.name
  node_count = var.min_node_count
  project    = var.project_id

  node_locations = var.zones

  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  upgrade_settings {
    max_surge       = 5
    max_unavailable = 2
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      env = var.gke_name
    }

    # Google recommends custom service accounts that have cloud-platform scope
    # and permissions granted via IAM Roles
    service_account = google_service_account.gke_sa.email
    tags            = ["gke"]

    machine_type = var.node_machine_type
    disk_size_gb = var.disk_size_gb
    disk_type    = "pd-balanced"
    image_type   = "UBUNTU_CONTAINERD"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    shielded_instance_config {
      enable_secure_boot = true
    }
  }
}
EOF

cat > variables.tf << 'EOF'
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
EOF

cat > outputs.tf << 'EOF'
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
EOF

# Go back to root directory
cd ../../

# Create installation script with credentials handling
cat > scripts/install_dependencies.sh << 'EOF'
#!/bin/bash

set -e

echo "Installing dependencies for GCP Terraform project..."

# Update package lists
sudo apt-get update

# Install required packages
sudo apt-get install -y curl unzip apt-transport-https ca-certificates gnupg

# Install Terraform
echo "Installing Terraform..."
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install -y terraform

# Install Google Cloud SDK
echo "Installing Google Cloud SDK..."
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update && sudo apt-get install -y google-cloud-sdk google-cloud-sdk-gke-gcloud-auth-plugin

# Install kubectl
echo "Installing kubectl..."
sudo apt-get install -y kubectl

echo "All dependencies installed successfully!"
echo "Now you need to place your GCP service account JSON key in the credentials folder."
EOF

# Create setup script for credentials
cat > scripts/setup_credentials.sh << 'EOF'
#!/bin/bash

set -e

# Check if source path is provided
if [ $# -ne 1 ]; then
  echo "Usage: $0 /path/to/your/service-account.json"
  exit 1
fi

SOURCE_CREDS=$1

# Create credentials directory
mkdir -p credentials

# Copy credentials file to the proper location
cp "$SOURCE_CREDS" "./credentials/service-account.json"

echo "Credentials set up successfully at ./credentials/service-account.json"
echo "You can now run 'terraform init' and 'terraform plan'"
EOF

# Make scripts executable
chmod +x scripts/install_dependencies.sh scripts/setup_credentials.sh

# Create credentials directory
mkdir -p credentials

# Create README.md
cat > README.md << 'EOF'
# GCP Terraform Modules for VPC and GKE

This repository contains Terraform modules to deploy a fully-functional GCP environment with VPC, subnets, and GKE cluster.

## Prerequisites

- GCP Project with billing enabled
- Service account JSON key file with appropriate permissions
- Terraform and Google Cloud SDK installed (use the provided `scripts/install_dependencies.sh` script)

## Directory Structure

```
terraform-gcp-gke/
├── main.tf               # Main Terraform configuration
├── variables.tf          # Variable definitions
├── outputs.tf            # Output definitions
├── terraform.tfvars      # Variable values
├── credentials/          # Directory to store GCP service account key
│   └── service-account.json  # Your GCP service account key (you need to add this)
├── modules/
│   ├── network/          # Network module (VPC, subnets, NAT, firewall)
│   └── gke/              # GKE module (cluster, node pools, service accounts)
└── scripts/
    ├── install_dependencies.sh  # Script to install dependencies
    └── setup_credentials.sh     # Script to set up your GCP credentials
```

## Module Details

### Network Module

The Network module provisions:
- VPC with custom subnet configuration
- 1 public subnet with internet access
- 2 private subnets with Cloud NAT for outbound internet
- Firewall rules to allow only HTTPS (port 443) traffic to GKE
- Cloud Router and Cloud NAT for private subnets

### GKE Module

The GKE module provisions:
- GKE cluster with latest Kubernetes version
- Service accounts with appropriate IAM permissions
- Node pools with autoscaling configuration
- Private cluster configuration
- Security best practices (shielded nodes, private nodes)
- Advanced features (Dataplane V2, intra-node visibility, vertical pod autoscaling)

## Customizable Parameters

The module allows for configuring:
- VPC CIDR blocks and subnet ranges
- GKE cluster parameters (node pool sizes, machine types, disk sizes)
- Autoscaling parameters (min/max nodes, CPU, memory)
- Security settings (private endpoints, authorized networks)

## Usage

1. Install dependencies:
   ```bash
   chmod +x scripts/install_dependencies.sh
   ./scripts/install_dependencies.sh
   ```

2. Authenticate with GCP:
   ```bash
   gcloud auth login
   gcloud config set project YOUR_PROJECT_ID
   ```

3. Update `terraform.tfvars` with your project-specific values

4. Initialize Terraform:
   ```bash
   terraform init
   ```

5. Plan the deployment:
   ```bash
   terraform plan
   ```

6. Apply the configuration:
   ```bash
   terraform apply
   ```
7. Access your GKE cluster:
   ```bash
   gcloud container clusters get-credentials gke-cluster --region us-central1
