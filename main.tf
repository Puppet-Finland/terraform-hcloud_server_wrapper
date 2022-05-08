resource "hcloud_floating_ip" "hcloud_server_instance" {
  count     = var.floating_ip == "true" ? 1 : 0
  type      = "ipv4"
  server_id = hcloud_server.hcloud_server_instance.id
}

resource "aws_route53_record" "hcloud_server_instance" {
  count   = var.public_hostname == "false" ? 0 : 1
  zone_id = var.route53_zone_id
  name    = var.public_hostname
  type    = "A"
  ttl     = "300"
  records = [hcloud_floating_ip.hcloud_server_instance[0].ip_address]
}

resource "aws_route53_record" "hcloud_server_instance_ipv6" {
  count   = var.public_hostname == "false" ? 0 : 1
  zone_id = var.route53_zone_id
  name    = var.public_hostname
  type    = "AAAA"
  ttl     = "300"
  records = [hcloud_server.hcloud_server_instance.ipv6_address]
}

resource "hcloud_server" "hcloud_server_instance" {
  name         = var.hostname
  image        = var.image
  server_type  = var.server_type
  datacenter   = var.datacenter
  ssh_keys     = var.ssh_keys
  backups      = var.backups
  firewall_ids = var.firewall_ids
  user_data    = data.cloudinit_config.provision.rendered

  lifecycle {
    ignore_changes = [
      image,
      ssh_keys,
      user_data,
    ]
  }
}

# cloud-init config that installs the provisioning scripts
data "local_file" "write_scripts" {
  filename = "${path.module}/write-scripts.cfg"
}

# cloud-init config to run install-puppet.sh
data "template_file" "run_scripts" {
  template = file("${path.module}/run-scripts.cfg.tftpl")
  vars     = {
               hostname             = var.hostname,
               deployment           = var.deployment,
               install_puppet_agent = var.install_puppet_agent,
               puppet_env           = local.puppet_env,
               puppet_version       = var.puppet_version,
               puppetmaster_ip      = var.puppetmaster_ip,
             }
}

data "cloudinit_config" "provision" {
  gzip          = true
  base64_encode = true

  # The provisioning scripts are embedded using heredoc into a static
  # cloud-init config and gets written to disk using the write_files module. We
  # don't use a template here because Hashicorp in their infinite wisdom chose
  # ${} as the variable interpolation syntax in template files, and this happens
  # to collide with the POSIX shell variable interpolation syntax, and we don't
  # want to change our scripts for that reason alone.
  #
  part {
    content_type = "text/cloud-config"
    content      = data.local_file.write_scripts.content
  }

  # Run the provisioning scripts. This is a template so that we can
  # adjust the parameters passed to the scripts.
  part {
    content_type = "text/cloud-config"
    content      = data.template_file.run_scripts.rendered
  }
}
