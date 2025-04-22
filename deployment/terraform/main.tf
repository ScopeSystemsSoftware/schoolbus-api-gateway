terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
  backend "gcs" {
    bucket = "schoolbus-terraform-state"
    prefix = "schoolbus/api-gateway"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Apigee Organization
resource "google_apigee_organization" "org" {
  project_id                   = var.project_id
  analytics_region             = var.region
  description                  = "SchoolBus API Gateway Organization"
  authorized_network           = google_compute_network.apigee_network.id
  runtime_type                 = "CLOUD"
  billing_type                 = "PAYG"
  retention_period_in_days     = 30
  disable_vpc_peering          = false
  display_name                 = "SchoolBus API Gateway"
}

# Apigee Environment
resource "google_apigee_environment" "env" {
  name         = var.environment
  description  = "SchoolBus API Gateway ${var.environment} Environment"
  display_name = upper(var.environment)
  org_id       = google_apigee_organization.org.id
}

# Apigee Environment Group
resource "google_apigee_envgroup" "env_group" {
  name        = "${var.environment}-group"
  hostnames   = ["api.schoolbus.com"]
  org_id      = google_apigee_organization.org.id
}

# Apigee Environment Group Attachment
resource "google_apigee_envgroup_attachment" "env_attachment" {
  envgroup_id = google_apigee_envgroup.env_group.id
  environment = google_apigee_environment.env.name
}

# VPC Network for Apigee
resource "google_compute_network" "apigee_network" {
  name                    = "apigee-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "apigee_subnet" {
  name          = "apigee-subnet"
  ip_cidr_range = "10.0.0.0/22"
  region        = var.region
  network       = google_compute_network.apigee_network.id
}

# Firewall rules for Apigee
resource "google_compute_firewall" "apigee_allow_ingress" {
  name    = "apigee-allow-ingress"
  network = google_compute_network.apigee_network.id
  
  allow {
    protocol = "tcp"
    ports    = ["443", "8080", "3001", "3002"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["apigee"]
}

# API Proxy
resource "google_apigee_proxy" "schoolbus_api" {
  name            = "schoolbus-api"
  bundle          = "gs://schoolbus-apigee-bundles/schoolbus-api.zip" # Bundle generated from apiproxy directory
  bundle_hash     = filemd5("gs://schoolbus-apigee-bundles/schoolbus-api.zip")
  revision        = "1"
  org_id          = google_apigee_organization.org.id
  depends_on      = [google_apigee_environment.env]
}

# API Proxy Deployment
resource "google_apigee_deploy" "schoolbus_api_deploy" {
  proxy_id  = google_apigee_proxy.schoolbus_api.id
  env_id    = google_apigee_environment.env.id
  revision  = google_apigee_proxy.schoolbus_api.revision
  org_id    = google_apigee_organization.org.id
}

# Developer
resource "google_apigee_developer" "admin_developer" {
  email     = "admin@schoolbus.com"
  first_name = "Admin"
  last_name  = "User"
  user_name  = "admin"
  org_id     = google_apigee_organization.org.id
}

# Developer App
resource "google_apigee_developer_app" "admin_app" {
  name         = "schoolbus-admin-app"
  developer_id = google_apigee_developer.admin_developer.email
  org_id       = google_apigee_organization.org.id
}

# API Product
resource "google_apigee_product" "schoolbus_product" {
  name         = "schoolbus-api-product"
  display_name = "SchoolBus API Product"
  description  = "Product for SchoolBus APIs"
  approval_type = "auto"
  
  api_resources = ["/schoolbus/**"]
  
  environments = [
    google_apigee_environment.env.name
  ]
  
  attributes = {
    access          = "public"
    quota_limit     = "600"
    quota_interval  = "1"
    quota_timeunit  = "minute"
  }

  org_id = google_apigee_organization.org.id
}

# API Key
resource "google_apigee_app_key" "api_key" {
  app_id    = google_apigee_developer_app.admin_app.id
  api_products = [google_apigee_product.schoolbus_product.name]
  consumer_key = "abcdefghijklmnopqrstuvwxyz123456"
  org_id      = google_apigee_organization.org.id
}