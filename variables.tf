variable "my_ip" {
  description = "my computer's IP: used to create security group rules to allow ssh and http access to tinyproxy"
  type        = string
  sensitive   = true
}

variable "ssh_key_name" {
  description = "name of the ssh key to connect to EC2 instances"
  type        = string
  sensitive   = true
}
