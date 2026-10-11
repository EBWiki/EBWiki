locals {
  health_paths   = [for host in var.health_hosts : "${host}/health"]
  primary_domain = local.health_paths[0]
}
