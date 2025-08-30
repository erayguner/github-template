# Google Cloud Platform resources (conditional)

# Data sources for GCP
data "google_client_config" "current" {
  count = var.enable_gcp ? 1 : 0
}

data "google_compute_zones" "available" {
  count  = var.enable_gcp ? 1 : 0
  region = var.gcp_region
}

# GCP VPC Network
resource "google_compute_network" "main" {
  count = var.enable_gcp ? 1 : 0

  name                    = "${var.project_name}-vpc"
  auto_create_subnetworks = false
  description             = "VPC for ${var.project_name} project"
}

# GCP Subnet
resource "google_compute_subnetwork" "public" {
  count = var.enable_gcp ? 1 : 0

  name          = "${var.project_name}-public-subnet"
  ip_cidr_range = var.vpc_cidr
  region        = var.gcp_region
  network       = google_compute_network.main[0].id

  description = "Public subnet for ${var.project_name}"
}

# GCP Firewall Rules
resource "google_compute_firewall" "allow_http" {
  count = var.enable_gcp ? 1 : 0

  name    = "${var.project_name}-allow-http"
  network = google_compute_network.main[0].name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]

  description = "Allow HTTP and HTTPS traffic"
}

resource "google_compute_firewall" "allow_ssh" {
  count = var.enable_gcp ? 1 : 0

  name    = "${var.project_name}-allow-ssh"
  network = google_compute_network.main[0].name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-access"]

  description = "Allow SSH access"
}

# GCP Router and NAT (for private instances)
resource "google_compute_router" "main" {
  count = var.enable_gcp ? 1 : 0

  name    = "${var.project_name}-router"
  region  = var.gcp_region
  network = google_compute_network.main[0].id

  description = "Router for ${var.project_name} NAT"
}

resource "google_compute_router_nat" "main" {
  count = var.enable_gcp ? 1 : 0

  name                               = "${var.project_name}-nat"
  router                             = google_compute_router.main[0].name
  region                             = var.gcp_region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# GCP Compute Instance Example (commented out by default)
# resource "google_compute_instance" "example" {
#   count = var.enable_gcp ? 1 : 0
#
#   name         = "${var.project_name}-instance"
#   machine_type = "e2-micro"
#   zone         = var.gcp_zone
#
#   boot_disk {
#     initialize_params {
#       image = "debian-cloud/debian-11"
#       size  = 20
#       type  = "pd-standard"
#     }
#   }
#
#   network_interface {
#     network    = google_compute_network.main[0].name
#     subnetwork = google_compute_subnetwork.public[0].name
#
#     access_config {
#       # Ephemeral public IP
#     }
#   }
#
#   tags = ["web-server", "ssh-access"]
#
#   metadata = {
#     ssh-keys = "user:${file("~/.ssh/id_rsa.pub")}"
#   }
#
#   service_account {
#     # Use default service account
#     scopes = ["cloud-platform"]
#   }
# }