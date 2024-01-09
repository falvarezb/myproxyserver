terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"         
    }
  }  
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "tinyproxy"
  cidr = "10.0.0.0/16"

  # select first available zone in the region
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
    cidr_blocks = [var.my_ip]
  }

  # allow ssh access from my local IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # allow http access to tinyproxy port from my local IP
  ingress {
    from_port   = 9888
    to_port     = 9888
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  tags = {
    Name = "tinyproxy"
  }
}

data "template_file" "cloud_init" {
  #file path is relative to the cwd of the process, not the module
  template = file("tinyproxy-cloud-init.yaml")
}

data "aws_ami" "ubuntu_22_04" {
  most_recent = true

  owners      = ["099720109477"] # Canonical's account ID

  filter {
    name   = "name"
    values = ["*ubuntu/images/*ubuntu*22.04*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "tinyproxy" {
  ami           = data.aws_ami.ubuntu_22_04.id
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
  #   touch /var/log/tinyproxy/tinyproxy.log
  #   chown tinyproxy:tinyproxy /var/log/tinyproxy/tinyproxy.log
  # EOF


  tags = {
    Name = "tinyproxy"
  }
}