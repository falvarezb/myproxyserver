variable "tags_common" {
  default = {
    app = "tinyproxy"
  }
}

provider "aws" {
  region = "eu-west-1"

  default_tags {
    tags = var.tags_common
  }
}

provider "aws" {
  alias  = "us"
  region = "us-east-1"

  default_tags {
    tags = var.tags_common
  }
}

provider "hcp" {
  client_id     = var.hcp_client_id
  client_secret = var.hcp_client_secret
}

module "tinyproxy_eu_west_1" {
  source = "./modules/tinyproxy"

  my_ip        = var.my_ip
  ssh_key_name = var.ssh_key_name
}

module "tinyproxy_us_east_1" {
  source = "./modules/tinyproxy"

  my_ip        = var.my_ip
  ssh_key_name = var.ssh_key_name
  providers = {
    aws = aws.us
  }
}

# TINYPROXY INSPECTOR  
# ec2 instance created in the default VPC in eu-west-1 (random AZ and subnet)
# contains a simple http server that listens on port 8000 to examine requests from tinyproxy

data "template_file" "cloud_init" {
  #file path is relative to the cwd of the process, not the module
  template = file("inspector-cloud-init.yaml")
}
resource "aws_security_group" "tinyproxy_inspector" {
  name_prefix = "tinyproxy_inspector-sg-"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow ssh access from my local IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # in theory, access should be restricted to the tinyproxy instances but given that this is supposed
  # to be a short-lived instance to run a few tests, we leave it open to the world
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tinyproxy_inspector"
  }
}

/*===Code to fetch the AMI ID from the manifest.auto.tfvars.json ===*/
# resource "null_resource" "ami_id" {
#   triggers = {
#     ami_value = split(":", element(var.builds, 0).artifact_id)[1]
#   }
# }

data "hcp_packer_image" "tinyproxy-inspector" {
  bucket_name     = "tinyproxy-inspector"
  channel         = "latest"
  cloud_provider  = "aws"
  region          = "eu-west-1"
}

resource "aws_instance" "tinyproxy_inspector" {
  # Ubuntu, 22.04
  # ami           = resource.null_resource.ami_id.triggers.ami_value  
  ami           = data.hcp_packer_image.tinyproxy-inspector.cloud_image_id
  instance_type = "t2.nano"

  key_name                    = var.ssh_key_name
  vpc_security_group_ids      = [aws_security_group.tinyproxy_inspector.id]
  associate_public_ip_address = true

  user_data = data.template_file.cloud_init.rendered


  tags = {
    Name = "tinyproxy_inspector"
  }
}
