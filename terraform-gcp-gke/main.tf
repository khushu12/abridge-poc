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
