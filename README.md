# abridge-poc
Note: Develop branch has prebuilt dirs. Use main branch for brand new setup.

The project is build assuming it will be running on Ubuntu 22 or greater box.

Run the script myscript.sh

./myscript.sh

This will build all the dir structure and modules and dependency scripts.
structure
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



## Prerequisites

- GCP Project with billing enabled
- Service account JSON key file with appropriate permissions
  Store the key under credentials folder with name service-account.json
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
terraform.tfvars is the file where we can provide custom vars for changing subnet cidr, autoscaling node config and other vars.

## Module Details

### Network Module

The Network module provisions:
- VPC with custom subnet configuration
- 1 public subnet with internet access(optional)
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
