variable "azure_subscription_id" {}
variable "azure_client_id" {}
variable "azure_client_secret" {}
variable "azure_tenant_id" {} 
variable "azure_vm_username" {}
variable "azure_vm_password" {}

variable "vm_size" {
    description = "VM instance size"
    default = "Standard_B1ms"
}
variable "vm_image_publisher" {
    description = "VM image vendor"
    default = "MicrosoftWindowsServer"
}
variable "vm_image_offer" {
    description = "VM image vendor's VM offering"
    default = "WindowsServer"
}
variable "vm_image_sku" {
    default = "2016-Datacenter"
}
variable "vm_image_version" {
    description = "vm image version"
    default = "latest"
}