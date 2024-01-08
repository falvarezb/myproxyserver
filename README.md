---
runme:
  id: 01HH4XYCPNVMYRV4GTBNZKNK0X
  version: v2.0
---

# myproxyserver

Terraform configuration to deploy a personal proxy server based on [tinyproxy](http://tinyproxy.github.io)

## Tinyproxy server
The project configuration allows deploying tinyproxy in EC2 instances in different AWS regions. 

Tinyproxy configuration is defined inside the file `tinyproxy-cloud-init.yaml`

### Useful information
- [Tinyproxy documentation](http://tinyproxy.github.io)

- [Tinyproxy configuration](http://tinyproxy.github.io/#configfile)
- configuration file path: `/etc/tinyproxy/tinyproxy.conf`
- log file path: `/var/log/tinyproxy/tinyproxy.log`

### Testing tinyproxy
- from inside the machine: `http_proxy=127.0.0.1:9888 curl example.com`

- from outside the machine: `http_proxy=<public_ip>:9888 curl example.com`
- https://ipleak.net
- https://www.dnsleaktest.com

### Debugging tinyproxy
- service status: `systemctl status tinyproxy`

- service restart: `systemctl restart tinyproxy`
- `sudo apt install -y net-tools`
- `netstat -tulpn | grep 9888`

### Notes:
The tinyproxy package distributes with Ubuntu 22.04 is not the latest version and some issues have been noted:
- hitting tinyproxy from the own machine fails `http_proxy=127.0.0.1:9888 curl example.com`

- proxying tinyproxy itself, `http_proxy=<public_ip>:9888 curl <public_ip>:9888`, results in an infinite loop that seems to be fixed on the latest version


## Inspector

In order to debug/examine the http requests re-written by tinyproxy, the terraform script also deploys a single instance containing a Python http server listening on port 8000. This server returns the list of headers of the http request.

To send http requests to the inspector instance, tinyproxy upstream configuration needs to point to said instance, e.g.

`upstream http <ip>:8000 "fjab.com"`

This change may be made:

- manually by ssh-ing into the machine, updating the configuration file and restarting the service
- manually by updating `tinyproxy-cloud-init.yaml` and re-running terraform (in most of the cases, the 'user_data' changes seem not to be applied; in that case, it is preferable to run `terraform replace`)

## Tech stack

Terraform and Packer

Packer is used to create the inspector image: the image is created on AWS's eu-west-1 and pushed to HCP registry. Then the image is deployed in the default VPC by Terraform by querying the HCP registry.

On the other hand, the provisioning of the tinyproxy instances is fully done through cloud-init. Each tinyproxy instance is created in its own VPC within the specified region.

## Other resources

### HTTP and Proxies RFC

https://www.rfc-editor.org/rfc/rfc9110#name-introduction

https://www.rfc-editor.org/rfc/rfc1919.html#page-2

### How can I use a single SSH key pair for all my AWS Regions?

https://repost.aws/knowledge-center/ec2-ssh-key-pair-regions

### Troubleshooting user_data related issues in AWS

https://citizix.com/how-to-use-terraform-aws-ec2-user_data-aws_instance/#using-shell-script-in-terraform-user_data

- /var/log/cloud-init.log
- /var/log/cloud-init-output.log
- /var/lib/cloud/instance/user-data.txt


### Packer example

https://medium.com/@yespratheesh/mastering-packer-how-to-automate-machine-image-creation-and-improve-infrastructure-management-7724d40bf879
