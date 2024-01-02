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

resource "aws_instance" "tinyproxy_inspector" {
  # Ubuntu, 22.04 LTS, amd64: ami-0694d931cee176e7d
  ami           = "ami-0694d931cee176e7d"
  instance_type = "t2.nano"

  key_name                    = var.ssh_key_name
  vpc_security_group_ids      = [aws_security_group.tinyproxy_inspector.id]
  associate_public_ip_address = true

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${path.root}/${var.ssh_key_name}.pem")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "httpserver.py"
    destination = "/home/ubuntu/httpserver.py"
  }

  provisioner "remote-exec" {
    inline = [
      "python3 httpserver.py &",
    ]
  }


  tags = {
    Name = "tinyproxy_inspector"
  }
}
