variable "vault_node_count" {
    description = "The number of vault replicas to run."
  default     = "1"
}

variable "consul_node_count" {
    description = "The number of consul replicas to run."
  default     = "1"
}

variable "csi_helm_version" {
  type        = string
  description = "Secrets Store CSI Driver Helm chart version"
  default     = "1.2.4"
}
