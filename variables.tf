variable "aws_regions" {
  type    = list(string)
  default = ["eu-west-1"]
  # to set custom values: terraform apply -var="regions=['us-east-1', 'us-west-2']"
}

variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "eu-west-1"
}

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
