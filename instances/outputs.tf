# eu-west-1
output "tinyproxy_ip_eu_west_1" {
  value = module.tinyproxy_eu_west_1.tinyproxy_ip
}

output "availability_zones_eu_west_1" {
  value = module.tinyproxy_eu_west_1.availability_zones
}

output "tinyproxy_ami_id_eu_west_1" {
  value = module.tinyproxy_eu_west_1.tinyproxy_ami_id
}


# us-east-1
output "tinyproxy_ip_us_east_1" {
  value = module.tinyproxy_us_east_1.tinyproxy_ip
}

output "availability_zones_us_east_1" {
  value = module.tinyproxy_us_east_1.availability_zones
}

output "tinyproxy_ami_id_us_east_1" {
  value = module.tinyproxy_us_east_1.tinyproxy_ami_id
}

# tinyproxy inspector
output "tinyproxy_inspector_ip" {
  value = aws_instance.tinyproxy_inspector.public_ip
}

output "tinyproxy_inspector_ami_id" {
  value = aws_instance.tinyproxy_inspector.ami
}