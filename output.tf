output "tinyproxy_ip" {
  value = aws_instance.tinyproxy.public_ip
}

output "availability_zones" {
  value = data.aws_availability_zones.available.names[0]
}