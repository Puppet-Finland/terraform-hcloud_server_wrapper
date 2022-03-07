variable "firewall_ids" {
  type    = list(string)
  default = []
}

variable "hostname" {
  type = string
}

variable "puppetmaster_ip" {
  type = string
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
  default = "centos-7"
}

variable "server_type" {
  type = string
  default = "cx11"
}

variable "datacenter" {
  type = string
  default = "hel1-dc2"
}
