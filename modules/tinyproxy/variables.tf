variable "my_ip" {
  description = "my computer's IP"
  type        = string
  sensitive   = true
}

variable "ssh_key_name" {
  description = "name of the ssh key to connect to EC2 instances"
  type        = string
  sensitive   = true
}
