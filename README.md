# Creating Windows and Linux Virtual Machines using Terraform

<!-- TOC -->

- [Development Environment Setup](#development-environment-setup)
- [Create Windows Virtual Machine](#create-windows-virtual-machine)
- [Create Linux Virtual Machine](#create-linux-virtual-machine)
- [Cleanup the resources](#cleanup-the-resources)

<!-- /TOC -->

### Development Environment Setup
- Install the [Terraform CLI](https://learn.hashicorp.com/tutorials/terraform/install-cli) 
- Install the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)

### Create Windows Virtual Machine 
- Clone this repo to a folder
- Open a command prompt and navigate to repo folder i.e. terraform-azure\windows
- Run `az login` to connect to Azure 

- Initialize the `Terraform` using below command, this will install the required plugins to current folder
	```
	$ terraform init
	```
    Output:
    ```
        Initializing the backend...

        Initializing provider plugins...
        - Checking for available provider plugins...
        - Downloading plugin for provider "azurerm" (hashicorp/azurerm) 2.25.0...

        Terraform has been successfully initialized!

        You may now begin working with Terraform. Try running "terraform plan" to see
        any changes that are required for your infrastructure. All Terraform commands
        should now work.
    ```
- Run `Terraform Plan` to see what resources will be created

	```
	$ terraform plan
	```
    Output:
    ```
        Terraform will perform the following actions:

        # azurerm_virtual_machine.terraform_vm will be created
        + resource "azurerm_virtual_machine" "terraform_vm" {
            ...............
            ...............

        # azurerm_virtual_network.terraform_network will be created
        + resource "azurerm_virtual_network" "terraform_network" {
            ...............
            ...............

        ...............
        ...............

        Plan: 10 to add, 0 to change, 0 to destroy.

        ------------------------------------------------------------------------

    ```

- If plan looks good, then run `Terraform Apply` to create infrastructure

	```
	$ terraform apply
	```
    Output:
    ```
        Terraform will perform the following actions:

        # azurerm_virtual_machine.terraform_vm will be created
        + resource "azurerm_virtual_machine" "terraform_vm" {
            ...............
            ...............

        # azurerm_virtual_network.terraform_network will be created
        + resource "azurerm_virtual_network" "terraform_network" {
            ...............
            ...............

        ...............
        ...............

        Apply complete! Resources: 10 added, 0 changed, 0 destroyed.
    ```

### Create Linux Virtual Machine 
- Clone this repo to a folder
- Open command prompt and navigate to repo folder i.e. terraform-azure\linux
- Run `az login` to connect to Azure 

- Repeat above `terraform` steps outlined (for windows) to create a Linux virtual machine


### Cleanup the resources
- Once you complete verifying and working with virtual machines
- Run `Terraform Destroy` to delete the resources from Azure

	```
	$ terraform destroy
	```
    Output:
    ```
        Terraform will perform the following actions:

        # azurerm_virtual_machine.terraform_vm will be destroyed
        + resource "azurerm_virtual_machine" "terraform_vm" {
            ...............
            ...............

        # azurerm_virtual_network.terraform_network will be destroyed
        + resource "azurerm_virtual_network" "terraform_network" {
            ...............
            ...............

        ...............
        ...............

        Destroy complete! Resources: 10 destroyed.
    ```