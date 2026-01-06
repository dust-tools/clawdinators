variable "hcloud_token" {
  description = "Hetzner API token. Prefer setting HCLOUD_TOKEN env var instead of tfvars."
  type        = string
  sensitive   = true
  default     = null
}

variable "ssh_key_names" {
  description = "Hetzner SSH key names to add to the server(s)."
  type        = list(string)
  default     = []
}

variable "ssh_key_name" {
  description = "Name for a generated SSH key (if ssh_public_key[_path] is set)."
  type        = string
  default     = "clawdinator"
}

variable "ssh_public_key" {
  description = "SSH public key contents to upload to Hetzner."
  type        = string
  default     = null
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key to upload to Hetzner."
  type        = string
  default     = null
}

variable "instance_count" {
  description = "Number of CLAWDINATOR hosts. POC can be 1."
  type        = number
  default     = 1
}

variable "name_prefix" {
  description = "Server name prefix (e.g., clawdinator)."
  type        = string
  default     = "clawdinator"
}

variable "server_type" {
  description = "Hetzner server type."
  type        = string
  default     = "cpx22"
}

variable "image" {
  description = "Base image. Prefer nixos after we set it up; ubuntu is fine for bootstrap."
  type        = string
  default     = "ubuntu-24.04"
}

variable "location" {
  description = "Hetzner location (e.g., fsn1, nbg1, hel1)."
  type        = string
  default     = "nbg1"
}

variable "volume_size_gb" {
  description = "Size of per-host volume for /var/lib/clawd. Set 0 to disable volumes."
  type        = number
  default     = 50
}
