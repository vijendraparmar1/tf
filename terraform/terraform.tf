variable "project" {default = "laod001-appdev-nolio01"}
variable "region" {default = "us-west1"}
variable "subnetwork" {default = "appdev-nolio01-usw1"}
variable "image" {default = "debian-11-bullseye-v20230629"}
variable "gc_credentials" {}
variable "infrastructure_name" {default = "demo-infrastructure"}
variable "jiraIssueId" {default = "no Jira Id"}
variable "zone" {default = "us-west1-b"}

variable "num_nodes" {
  description = "Number of nodes to create"
  default     = 1
}

locals {
	id = "${random_integer.name_extension.result}"
}

resource "random_integer" "name_extension" {
  min     = 1
  max     = 99999
}

provider "google" {
  credentials = "${var.gc_credentials}"
  project     = "${var.project}"
  region      = "${var.region}"
}

resource "google_compute_instance" "default" {
  count        = "${var.num_nodes}"
  project      = "${var.project}"
  zone         = "${var.zone}"
  name         = "${var.infrastructure_name}-${count.index + 1}-${local.id}"
  machine_type = "f1-micro"
  
  boot_disk {
    initialize_params {
      image = "${var.image}"
    }
  }
  
  network_interface {
    subnetwork = "${var.subnetwork}"
    subnetwork_project = "${var.project}"
  }
}

output "name_output" {
	description = "Instance name"
	value       = "${google_compute_instance.default.*.name[0]}"
}

output "project_output" {
	description = "Project name"
	value       = "${google_compute_instance.default.*.project[0]}"
}

output "internal_ip_output" {
	description = "Internal IP"
	value       = "${google_compute_instance.default.*.network_interface.0.network_ip}"
}
/*
provider "jira" {
  //url = "http://localhost:8100"       # Can also be set using the JIRA_URL environment variable
  //user = "Jenya"                      # Can also be set using the JIRA_USER environment variable
  //password = "${var.jiraPassword}"    # Can also be set using the JIRA_PASSWORD environment variable
}

resource "jira_comment" "example_comment" {
  body = "Infrastructure Name: ${google_compute_instance.default.*.name[0]} \r\n Project Name: ${google_compute_instance.default.*.project[0]} \r\n Internal IP: ${google_compute_instance.default.*.network_interface.0.network_ip[0]}"
  issue_key = "${var.jiraIssueId}"
}
*/
