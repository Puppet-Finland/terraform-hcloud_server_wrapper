resource "hcloud_floating_ip" "hcloud_server_instance" {
  count = var.floating_ip == "true" ? 1 : 0
  type = "ipv4"
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
  name = var.hostname
  image = var.image
  server_type = var.server_type
  datacenter = var.datacenter
  ssh_keys = var.ssh_keys
  backups = var.backups
  firewall_ids = var.firewall_ids

  lifecycle {
    ignore_changes = [
      ssh_keys,
      image
    ]
  }

  connection {
    type = "ssh"
    user = "root"
    host = self.ipv4_address
  }

  # Taken from aws_instance_wrapper
  provisioner "file" {
    source = "${path.module}/install-puppet.sh"
    destination = "/tmp/install-puppet.sh"
  }

  provisioner "file" {
    content = "deployment: ${var.deployment}"
    destination = "/tmp/deployment.yaml"
  }

  provisioner "remote-exec" {
    inline = concat(["echo Provisioning"], [for command in local.deployment_fact_commands: command if var.deployment != ""])
   }

  provisioner "remote-exec" {
    inline = concat(["echo Provisioning"], [local.set_hostname_command], [local.etc_hosts_command], [for command in local.puppet_agent_commands: command if var.install_puppet_agent])
  }

  provisioner "remote-exec" {
    inline = ["rm -f /tmp/install-puppet.sh /tmp/deployment.yaml"]
  }
}
