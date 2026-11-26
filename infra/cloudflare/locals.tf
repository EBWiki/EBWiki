locals {
  health_path_prefix = "/health"

  health_destinations = [
    for hostname in var.health_protected_hostnames : {
      type = "public"
      uri  = "${hostname}${local.health_path_prefix}"
    }
  ]

  primary_health_domain = "${var.health_protected_hostnames[0]}${local.health_path_prefix}"
}
