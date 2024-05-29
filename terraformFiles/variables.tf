variable client_id {
  default = "your_client_id"
}

variable client_secret {
  default = "your_client_secret"
}

variable "subscription_id" {
  default = "your_subscription_id"
}
variable "tenant_id" {
  default = "your_tenant_id"
}

variable "location" {
  default = "West Europe"
}

variable "rg_name" {
  default = "your_resource_group_name"
}

variable "hostpool_blue_name" {
  default = "hostpool_blue"
}

variable "hostpool_green_name" {
  default = "hostpool_green"
}

variable "app_group_blue_name" {
  default = "app-group-blue-desktop"
}

variable "app_group_green_name" {
  default = "app-group-green-desktop"
}

variable "workspace_name" {
  default = "workspace_desktop"
}

variable "compute_gallery_name" {
  default = "compute_gallery"
}

variable "virtual_network_name" {
  default = "avd_virtual_network"
}

variable "subnet_1_name" {
  default = "avd_subnet_1"
}

variable "subnet_2_name" {
  default = "avd_subnet_2"
}

variable "nsg_name" {
  default = "avd_nsg_1"
}

variable "rdp_rule_inbound" {
  default = "allowRdpInbound"
}

variable "rdp_rule_outbound" {
  default = "allowRdpOutbound"
}

variable "http_rule_inbound" {
  default = "allowHttpInbound"
}
variable "http_rule_outbound" {
  default = "allowHttpOutbound"
}

variable "https_rule_inbound" {
  default = "allowHttpsInbound"
}

variable "https_rule_outbound" {
  default = "allowHttpsOutbound"
}

variable "ssh_rule_inbound" {
  default = "allowSshInbound"
}

variable "ssh_rule_outbound" {
  default = "allowSshOutbound"
}
variable "number_of_session_hosts" {
  default = 2
}
variable "prefix_blue" {
  default = "avd-windows-blue-"
}

variable "prefix_green" {
  default = "avd-windows-green-"
}

variable "admin_username" {
  default = "username"
}

variable "admin_password" {
  default = "yourSuperSecretPassword!"
}

variable "vm_size" {
  default = "Standard_B2s"
}

variable "cg_image_name" {
  default = "windowsBasicAvdImage"
}
