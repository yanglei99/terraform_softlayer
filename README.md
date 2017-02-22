# Terraform on Softlayer

[Terraform Softlayer Provider](https://github.com/softlayer/terraform-provider-softlayer)

## Notes on environment setup

* The latest Softlayer Provider binary download (1.3.0) does not work with Terraform 0.8.x. Workaround the issue by downloading terraform 0.7.x 

* make sure the binary is executable

	chmod +x <the downloaded softlayer binary>



## Scenarios

* [Basic](basic/sl_basic.tf). Provision 2 VMs with a new SSH Key
* [Auto Scale Group](asg/sl_asg.tf). Provision Auto Scale Group and reuse the created SSH Key
* [Mesosphere DC/OS](dcos/README.md). Provision Mesosphere DC/OS cluster


### Useful Terraform Command

	terraform plan
	terraform graph
	
	terraform apply
	terraform show
	
	terraform plan --destroy
	terraform destroy

