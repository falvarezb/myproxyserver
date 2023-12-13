# https://docs.aws.amazon.com/lambda/latest/dg/welcome.html

provider "aws" {
    region = var.aws_region

  default_tags {
    tags = {
      app = "tinyproxy"
    }
  }
}

provider "aws" {
  alias  = "us"
  region = "us-west-1"

  default_tags {
    tags = {
      app = "tinyproxy"
    }
  }
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "tinyproxy"
  cidr = "10.0.0.0/16"

  azs             = [data.aws_availability_zones.available.names[0]]
  public_subnets  = ["10.0.1.0/24"]

  tags = {
    Terraform = "true"    
  }
}

resource "aws_security_group" "tinyproxy" {
  name_prefix = "tinyproxy-sg-"
  vpc_id      = module.vpc.vpc_id


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow https access for method CONNECT
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow ssh access from my local IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  tags = {
    Name = "tinyproxy"
  }
}

data "template_file" "cloud_init" {
  template = file("cloud-init.yaml")
}

resource "aws_instance" "tinyproxy" {
  # Ubuntu, 22.04 LTS, amd64: ami-0694d931cee176e7d
  ami           = "ami-0694d931cee176e7d"
  instance_type = "t2.nano"

  key_name               = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.tinyproxy.id]

  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true  

  user_data = data.template_file.cloud_init.rendered
  
  # user_data = <<-EOF
  #   #!/bin/bash
  #   set -ex
  #   apt-get update    
  #   apt-get -y install tinyproxy
  # EOF


  tags = {
    Name = "tinyproxy"
  }
}