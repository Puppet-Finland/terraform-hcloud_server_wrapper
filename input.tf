variable "firewall_ids" {
  type    = list(string)
  default = []
}

variable "hostname" {
  type = string
}

# Whether to install Puppet Agent or not.
variable "install_puppet_agent" {
  type    = bool
  default = true
}

variable "puppet_environment" {
  type = string
  default = ""
}

variable "puppet_version" {
  type = number
  default = 7
}

variable "puppetmaster_ip" {
  type = string
  default = ""
}

variable "ssh_keys" {
  type = list
}

variable "floating_ip" {
  type = string
  default = "false"
}

# The public hostname of the server. Added to Route 53 if not set to "false"
variable "public_hostname" {
  type = string
  default = "false"
}

variable "route53_zone_id" {
  type = string
  default = "false"
}

variable "backups" {
  type = string
  default = "true"
}

variable "deployment" {
  type = string
  default = "production"
}

variable "image" {
  type = string
}

variable "server_type" {
  type = string
  default = "cx11"
}

variable "datacenter" {
  type = string
  default = "hel1-dc2"
}

variable "labels" {
  type = map
  default = {}
}
