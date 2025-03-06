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
