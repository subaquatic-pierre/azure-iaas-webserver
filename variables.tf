variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default     = "udacity"
}

variable "username" {
  description = "Enter username to associate with the machine"
  default     = "udacity"

}

variable "password" {
  description = "Enter password to use to access the machine"
  default     = "Udacity123"

}

variable "instance_count" {
  description = "Enter number of vm instances for this configuration"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default     = "eastus"
}

variable "image_id" {
  description = "Enter the ID for the image which will be used for craeting the Virtual Machines"
  default     = "/subscriptions/fce5d291-15d7-436d-a736-05219bee3b1e/resourceGroups/packer-image-rg/providers/Microsoft.Compute/images/project1-image"
}
