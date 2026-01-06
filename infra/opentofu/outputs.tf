output "server_names" {
  value = [for s in hcloud_server.clawdinator : s.name]
}

output "server_ipv4" {
  value = { for s in hcloud_server.clawdinator : s.name => s.ipv4_address }
}
