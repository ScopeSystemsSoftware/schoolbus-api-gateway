output "apigee_org_id" {
  description = "Apigee Organization ID"
  value       = google_apigee_organization.org.id
}

output "apigee_environment_id" {
  description = "Apigee Environment ID"
  value       = google_apigee_environment.env.id
}

output "apigee_endpoint_url" {
  description = "Apigee Endpoint URL"
  value       = "https://${one(google_apigee_envgroup.env_group.hostnames)}/schoolbus"
}

output "api_key" {
  description = "API Key for accessing the SchoolBus API"
  value       = google_apigee_app_key.api_key.consumer_key
  sensitive   = true
}

output "developer_email" {
  description = "Developer email"
  value       = google_apigee_developer.admin_developer.email
}

output "apigee_network_id" {
  description = "Apigee Network ID"
  value       = google_compute_network.apigee_network.id
}

output "apigee_subnet_id" {
  description = "Apigee Subnet ID"
  value       = google_compute_subnetwork.apigee_subnet.id
}