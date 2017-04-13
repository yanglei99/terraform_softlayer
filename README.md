# Terraform on Softlayer

[Terraform Softlayer Provider](https://github.com/softlayer/terraform-provider-softlayer)


## Notes on environment setup

Download Terraform binary and set onto PATH

Download Terraform Softlayer Provider binary and enable it in `~/.terraformrc`. Make sure the binary is executable. 

	providers {
    	softlayer = “/.../terraform-provider-softlayer_xxxx"
	}

## Scenarios

* [Basic](basic/sl_basic.tf). Provision 2 VMs with a new SSH Key
* [Auto Scale Group](asg/sl_asg.tf). Provision Auto Scale Group and reuse the created SSH Key
* [Mesosphere DC/OS](dcos/README.md). Provision Mesosphere DC/OS cluster


### Verified

* Terraform: 0.8.7
* Terraform Softlayer Provider: 1.4.1


### Useful Terraform Command

	terraform plan
	terraform graph
	
	terraform apply
	terraform show
	
	terraform plan --destroy
	terraform destroy

