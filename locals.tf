locals {
  etc_hosts_command = var.puppetmaster_ip == "" ? "echo Not modifying /etc/hosts" : "echo ${var.puppetmaster_ip} puppet|sudo tee -a /etc/hosts"

  # Command to run to set up the deployment fact for Puppet
  deployment_fact_commands  = ["sudo mkdir -p /etc/facter/facts.d",
                               "sudo mv /tmp/deployment.yaml /etc/facter/facts.d/",
                               "sudo chown -R root:root /etc/facter"]

  # Command to run if install_puppet_agent == true
  puppet_agent_commands = ["sudo chmod +x /tmp/install-puppet.sh",
                           "sudo /tmp/install-puppet.sh -n ${var.hostname} -e ${var.deployment} -s" ]

  set_hostname_command = "sudo hostnamectl set-hostname ${var.hostname}"
}
