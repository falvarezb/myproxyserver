output "tinyproxy_ip_eu_west_1" {
  value = module.tinyproxy_eu_west_1.tinyproxy_ip
}

output "tinyproxy_ip_us_east_1" {
  value = module.tinyproxy_us_east_1.tinyproxy_ip
}

output "availability_zones_eu_west_1" {
  value = module.tinyproxy_eu_west_1.availability_zones
}

output "availability_zones_us_east_1" {
  value = module.tinyproxy_us_east_1.availability_zones
}

output "ubuntu_22_04_ami_id_eu_west_1" {
  value = module.tinyproxy_eu_west_1.ubuntu_22_04_ami_id
}

output "ubuntu_22_04_ami_id_us_east_1" {
  value = module.tinyproxy_us_east_1.ubuntu_22_04_ami_id
}