locals {
  default_role_name  = "${var.component}-${var.deployment_identifier}"
  prefixed_role_name = var.role_name_prefix != null ? "${var.role_name_prefix}-${local.default_role_name}" : local.default_role_name
  resolved_role_name = var.role_name != null ? var.role_name : local.prefixed_role_name
}
