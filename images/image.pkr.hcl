packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

variable "region" {
  type    = string
  default = "eu-west-1"
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }


# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioners and post-processors on a
# source.
source "amazon-ebs" "tinyproxy-inspector" {
  ami_name      = "tinyproxy-inspector-${local.timestamp}"
  instance_type = "t2.micro"
  region        = var.region
  source_ami_filter {
    filters = {
      name                = "*ubuntu/images/*ubuntu*22.04*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

# a build block invokes sources and runs provisioning steps on them.
build {

  hcp_packer_registry {
    bucket_name = "tinyproxy-inspector"
    description = "Image to create a simple Python HTTP server to inspect the traffic coming out of Tinyproxy"

    bucket_labels = {
      "owner"          = "fjab76"
      "os"             = "Ubuntu",
      "ubuntu-version" = "22.04",
    }

    build_labels = {
      "build-time"   = timestamp()
      "build-source" = basename(path.cwd)
    }
  }

  sources = ["source.amazon-ebs.tinyproxy-inspector"]

  provisioner "file" {
    source      = "./httpserver.py"
    destination = "/home/ubuntu/httpserver.py"
  }

  /*==Deletion of manifest file containing old AMI ID==*/
  post-processor "shell-local" {
    inline = ["rm -rf ../manifest.auto.tfvars.json"]
  }

  /*==Creation of manifest file containing new AMI ID==*/
  post-processor "manifest" {
    output     = "../manifest.auto.tfvars.json"
    strip_path = true
  }
}
