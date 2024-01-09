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
- `terraform output` returns info about the deployed instances, e.g.

```toml {"id":"01HKN4R7G3DBZFRHM950E1BPSC"}
tinyproxy_ami_id_eu_west_1 = "ami-0905a3c97561e0b69"
tinyproxy_ami_id_us_east_1 = "ami-0c7217cdde317cfec"
tinyproxy_inspector_ami_id = "ami-0f191c1b6377a98fc"
tinyproxy_inspector_ip = "52.214.235.33"
tinyproxy_ip_eu_west_1 = "3.253.131.243"
tinyproxy_ip_us_east_1 = "54.175.88.143"
availability_zones_eu_west_1 = "eu-west-1a"
availability_zones_us_east_1 = "us-east-1a"
```

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

The tinyproxy package distributed with Ubuntu 22.04 is not the latest version and some issues have been noted:

- hitting tinyproxy from the own machine fails `http_proxy=127.0.0.1:9888 curl example.com`
- proxying tinyproxy itself, `http_proxy=<public_ip>:9888 curl <public_ip>:9888`, results in an infinite loop that seems to be fixed on the latest version

## Inspector

In order to debug/examine the http requests re-written by tinyproxy, the terraform script also deploys a single instance containing a Python http server listening on port 8000. This server returns the list of headers of the http request.

To send http requests to the inspector instance, tinyproxy upstream configuration needs to point to said instance, e.g.

`upstream http <inspector_ip>:8000 "fjab.com"`

This change may be made:

- manually by ssh-ing into the machine, updating the configuration file and restarting the service
- manually by updating `tinyproxy-cloud-init.yaml` and re-running terraform (in most of the cases, the 'user_data' changes seem not to be applied; in that case, it is preferable to run __terraform replace__, e.g. `terraform apply -var-file secrets.tfvars -replace module.tinyproxy_eu_west_1.aws_instance.tinyproxy --auto-approve`)

## Tech stack

Terraform and Packer

Packer is used to create the inspector image: the image is created on AWS's eu-west-1 and pushed to HCP registry. Then the image is deployed in the default VPC by Terraform by querying the HCP registry. HCP registry credentials are stored in a separate file, `secrets.tfvars`, not included in the repository.

On the other hand, the provisioning of the tinyproxy instances is fully done through cloud-init. Each tinyproxy instance is created in its own VPC within the specified region.

Before running Packer inside the folder `images`, it is necessary to configure the environmet with the AWS credentials, e.g. `export AWS_PROFILE=<myprofile>`

### Secrets

The file `secrets.tfvars` is not included in the repository and contains the following variables:

- `my_ip`: the public IP of the machine from which the proxy server will be accessed
- `ssh_key_name`: the name of the ssh key to be used to access the instances
- `hcp_client_id`: the client id of the HCP registry
- `hcp_client_secret`: the client secret of the HCP registry

### Environment configuration

Terraform is configured to run on Terraform Cloud and is to be executed from the folder `instances`. Thus, the local environment must be configured to connect to Terraform Cloud. This is done by running `terraform login` and following the instructions.

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
