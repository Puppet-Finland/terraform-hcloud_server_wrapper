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
  provisioner "remote-exec" {
    inline = [ "echo ${var.puppetmaster_ip} puppet|sudo tee -a /etc/hosts" ]
  }

  provisioner "file" {
    source = "${path.module}/install-puppet.sh"
    destination = "/tmp/install-puppet.sh"
  }

  provisioner "remote-exec" {
    inline = [ "sudo mkdir -p /etc/puppetlabs/facter/facts.d" ]
  }

  provisioner "file" {
    content = "deployment: ${var.deployment}"
    destination = "/tmp/deployment.yaml"
  }

  provisioner "remote-exec" {
    inline = [ "sudo mv /tmp/deployment.yaml /etc/puppetlabs/facter/facts.d/",
               "sudo chown -R root:root /etc/puppetlabs/facter",
               "chmod +x /tmp/install-puppet.sh",
               "sudo /tmp/install-puppet.sh -n ${var.hostname} -e ${var.deployment} -s" ]
  }
}
