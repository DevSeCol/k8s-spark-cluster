provider "google" {
  credentials = "${file("terraform.json")}"
  project = var.project
  region = var.region
  zone = var.zone
}

resource "google_container_cluster" "cluster" {
  name                      = var.cluster_name
  location                  = var.zone
  remove_default_node_pool  = true
  initial_node_count        = 1
  network                   = var.cluster_network
  subnetwork                = var.cluster_subnetwork
}

resource "google_container_node_pool" "preemptible_nodes" {
  name       = "another-pool"
  location   = google_container_cluster.cluster.location
  cluster    = google_container_cluster.cluster.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = var.machine_type
    
    service_account = var.service_account
    
    labels = {
      machine-type = "preemtible"
    }

    tags = ["spark-cluster"]

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}