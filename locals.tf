locals {
  puppet_env = var.puppet_environment == "" ? var.deployment : var.puppet_environment
}
