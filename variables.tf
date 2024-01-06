variable "my_ip" {
  description = "my computer's IP: used to create security group rules to allow ssh and http access to tinyproxy"
  type        = string
  sensitive   = true
}

variable "ssh_key_name" {
  description = "name of the private key to connect to EC2 instances"
  type        = string
  sensitive   = true
}

variable "private_key" {
  description = "private key to connect to EC2 instances"
  type        = string
  sensitive   = true
}

variable "builds" {
  type = list(
    object(
      {
        name            = string,
        builder_type    = string,
        build_time      = number,
        files           = list(object({ name = string, size = number })),
        artifact_id     = string,
        packer_run_uuid = string
      }
    )
  )
  description = "List of images, as generated by Packer's 'Manifest' post-processor."
}

variable "last_run_uuid" {
  type = string
}
