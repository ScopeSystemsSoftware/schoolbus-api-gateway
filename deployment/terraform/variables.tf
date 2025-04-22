variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "Google Cloud Region"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Deployment environment (e.g., dev, test, prod)"
  type        = string
  default     = "dev"
}

variable "proxy_bundle_path" {
  description = "Path to the API proxy bundle .zip file"
  type        = string
  default     = "gs://schoolbus-apigee-bundles/schoolbus-api.zip"
}