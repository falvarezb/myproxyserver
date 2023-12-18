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
  source    = "./modules/tinyproxy"  

  my_ip = var.my_ip
  ssh_key_name = var.ssh_key_name
}

module "tinyproxy_us_east_1" {
  source    = "./modules/tinyproxy"  

  my_ip = var.my_ip
  ssh_key_name = var.ssh_key_name
  providers = {
    aws = aws.us
  }
}

