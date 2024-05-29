# For retrieving authentication details
data "azurerm_client_config" "current" {}

# Creating the resource group for the AVD environmentAanmaken van de resource group voor de AVD omgeving ten behoeve van bijbehorende resources
resource "azurerm_resource_group" "your_resource_group" {
  name     = var.rg_name
  location = var.location
}

# Creating the 'blue' hostpool
resource "azurerm_virtual_desktop_host_pool" "hostpool_blue" {
  location            = azurerm_resource_group.your_resource_group.location
  resource_group_name = azurerm_resource_group.your_resource_group.name

  name                     = var.hostpool_blue_name
  start_vm_on_connect      = true
  type                     = "Pooled"
  maximum_sessions_allowed = 5
  load_balancer_type       = "BreadthFirst"

  tags = {
    project = "Graduation Project"
  }
}

# Creating the 'green' hostpool
resource "azurerm_virtual_desktop_host_pool" "hostpool_green" {
  location            = azurerm_resource_group.your_resource_group.location
  resource_group_name = azurerm_resource_group.your_resource_group.name

  name                     = var.hostpool_green_name
  start_vm_on_connect      = true
  type                     = "Pooled"
  maximum_sessions_allowed = 5
  load_balancer_type       = "BreadthFirst"

  tags = {
    project = "Graduation Project"
  }
}

# creating the 'blue' application group
resource "azurerm_virtual_desktop_application_group" "app_group_blue" {
  name                = var.app_group_blue_name
  location            = azurerm_resource_group.your_resource_group.location
  resource_group_name = azurerm_resource_group.your_resource_group.name

  type          = "Desktop"
  host_pool_id  = azurerm_virtual_desktop_host_pool.hostpool_blue.id
  friendly_name = "Application group blauw"

  tags = {
    project = "Graduation Project"
  }
}

# Creating the 'green' application group
resource "azurerm_virtual_desktop_application_group" "app_group_green" {
  name                = var.app_group_green_name
  location            = azurerm_resource_group.your_resource_group.location
  resource_group_name = azurerm_resource_group.your_resource_group.name

  type          = "Desktop"
  host_pool_id  = azurerm_virtual_desktop_host_pool.hostpool_green.id
  friendly_name = "Application group green"

  tags = {
    project = "Graduation Project"
  }
}

# Creating the AVD workspace
resource "azurerm_virtual_desktop_workspace" "workspace_avd" {
  name                = "workspace"
  location            = azurerm_resource_group.your_resource_group.location
  resource_group_name = azurerm_resource_group.your_resource_group.name

  friendly_name                 = "AVD workspace"
  public_network_access_enabled = true

  tags = {
    project = "Graduation Project"
  }
}

# Creating the connection between the workspace and the preffered application group
resource "azurerm_virtual_desktop_workspace_application_group_association" "workspace_app_group_association" {
  workspace_id         = azurerm_virtual_desktop_workspace.workspace_avd.id
  application_group_id = azurerm_virtual_desktop_application_group.app_group_blue.id
}

# Creating the Shared Image Gallery for management of the AVD images
resource "azurerm_shared_image_gallery" "shared_image_gallery_avd" {
  name                = var.compute_gallery_name
  location            = azurerm_resource_group.your_resource_group.location
  resource_group_name = azurerm_resource_group.your_resource_group.name

  tags = {
    project = "Graduation Project"
  }
}

# Registration keys to add the session hosts to the host pool
resource "azurerm_virtual_desktop_host_pool_registration_info" "rk_hostpool_blue" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.hostpool_blue.id
  expiration_date = "2024-01-22T23:59:52Z"
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "rk_hostpool_green" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.hostpool_green.id
  expiration_date = "2024-01-22T23:59:52Z"
}

# Tokens for the registration keys
locals {
  registration_token_blue  = azurerm_virtual_desktop_host_pool_registration_info.rk_hostpool_blue.token
  registration_token_green = azurerm_virtual_desktop_host_pool_registration_info.rk_hostpool_green.token
}

# Creating network security group
resource "azurerm_network_security_group" "nsg_1" {
  name                = var.nsg_name
  location            = azurerm_resource_group.your_resource_group.location
  resource_group_name = azurerm_resource_group.your_resource_group.name
}
#Security rules for allowing RDP, HTTP, HTTPS, SSH
resource "azurerm_network_security_rule" "inbound_rdp" {
  name                        = var.rdp_rule_inbound
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.your_resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg_1.name
}

resource "azurerm_network_security_rule" "outbound_rdp" {
  name                        = var.rdp_rule_outbound
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.your_resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg_1.name
}

resource "azurerm_network_security_rule" "inbound_http" {
  name                        = var.http_rule_inbound
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.your_resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg_1.name
}

resource "azurerm_network_security_rule" "outbound_http" {
  name                        = var.http_rule_outbound
  priority                    = 110
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.your_resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg_1.name
}

resource "azurerm_network_security_rule" "inbound_https" {
  name                        = var.https_rule_inbound
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.your_resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg_1.name
}

resource "azurerm_network_security_rule" "outbound_https_rule" {
  name                        = var.https_rule_outbound
  priority                    = 120
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.your_resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg_1.name
}

resource "azurerm_network_security_rule" "inbound_ssh" {
  name                        = var.ssh_rule_inbound
  priority                    = 130
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.your_resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg_1.name
}

resource "azurerm_network_security_rule" "outbound_ssh" {
  name                        = var.ssh_rule_outbound
  priority                    = 130
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.your_resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg_1.name
}

# Creating Virtual Network to connect with the session hosts
resource "azurerm_virtual_network" "v_net" {
  name                = var.virtual_network_name
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.your_resource_group.location
  resource_group_name = azurerm_resource_group.your_resource_group.name
}

# Subnets for within the Virtual Network
resource "azurerm_subnet" "subnet_1" {
  name                 = var.subnet_1_name
  resource_group_name  = azurerm_resource_group.your_resource_group.name
  virtual_network_name = azurerm_virtual_network.v_net.name
  address_prefixes     = ["10.1.1.0/24"]

  depends_on = [azurerm_virtual_network.v_net]
}

resource "azurerm_subnet" "subnet_2" {
  name                 = var.subnet_2_name
  resource_group_name  = azurerm_resource_group.your_resource_group.name
  virtual_network_name = azurerm_virtual_network.v_net.name
  address_prefixes     = ["10.1.2.0/24"]

  depends_on = [azurerm_virtual_network.v_net]

}

# Add public IP addresses
resource "azurerm_public_ip" "public_ip_blue" {
  count               = var.number_of_session_hosts
  name                = "${var.prefix_blue}${count.index + 1}-publicip"
  resource_group_name = azurerm_resource_group.your_resource_group.name
  location            = azurerm_resource_group.your_resource_group.location
  allocation_method   = "Dynamic"
}

resource "azurerm_public_ip" "public_ip_green" {
  count               = var.number_of_session_hosts
  name                = "${var.prefix_green}${count.index + 1}-publicip"
  resource_group_name = azurerm_resource_group.your_resource_group.name
  location            = azurerm_resource_group.your_resource_group.location
  allocation_method   = "Dynamic"
}

# Add Network interface for both subnets
resource "azurerm_network_interface" "avd_nic_blue" {
  count               = var.number_of_session_hosts
  name                = "${var.prefix_blue}${count.index + 1}-nic"
  resource_group_name = azurerm_resource_group.your_resource_group.name
  location            = azurerm_resource_group.your_resource_group.location

  ip_configuration {
    name                          = "nic_ip_${count.index + 1}_config"
    subnet_id                     = azurerm_subnet.subnet_1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip_blue[count.index].id
  }
}

resource "azurerm_network_interface" "avd_nic_green" {
  count               = var.number_of_session_hosts
  name                = "${var.prefix_green}${count.index + 1}-nic"
  resource_group_name = azurerm_resource_group.your_resource_group.name
  location            = azurerm_resource_group.your_resource_group.location

  ip_configuration {
    name                          = "green_nic_ip_${count.index + 1}_config"
    subnet_id                     = azurerm_subnet.subnet_2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip_green[count.index].id
  }
}

# Using the Packer image that has been created to use for the session hosts
data "azurerm_shared_image" "avd_image" {
  name                = var.cg_image_name
  gallery_name        = var.compute_gallery_name
  resource_group_name = azurerm_resource_group.your_resource_group.name
}

# Creating the VMs so they can be used as the session hosts
resource "azurerm_windows_virtual_machine" "avd_blue_sh_vm" {
  count                 = var.number_of_session_hosts
  name                  = "${var.prefix_blue}${count.index + 1}"
  resource_group_name   = azurerm_resource_group.your_resource_group.name
  location              = azurerm_resource_group.your_resource_group.location
  size                  = var.vm_size
  network_interface_ids = ["${azurerm_network_interface.avd_nic_blue.*.id[count.index]}"]
  provision_vm_agent    = true
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  computer_name         = "avd-sh-blue-${count.index}"

  os_disk {
    name                 = "${lower(var.prefix_blue)}${count.index + 1}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_id = data.azurerm_shared_image.avd_image.id

  identity { type = "SystemAssigned" }
}

resource "azurerm_windows_virtual_machine" "avd_green_sh_vm" {
  count                 = var.number_of_session_hosts
  name                  = "${var.prefix_green}${count.index + 1}"
  resource_group_name   = azurerm_resource_group.your_resource_group.name
  location              = azurerm_resource_group.your_resource_group.location
  size                  = var.vm_size
  network_interface_ids = ["${azurerm_network_interface.avd_nic_green.*.id[count.index]}"]
  provision_vm_agent    = true
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  computer_name         = "avd-sh-green-${count.index}"

  os_disk {
    name                 = "${lower(var.prefix_green)}${count.index + 1}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_id = data.azurerm_shared_image.avd_image.id

  identity { type = "SystemAssigned" }
}


# Extensions for adding the session hosts to the right host pool
resource "azurerm_virtual_machine_extension" "vmext_dsc_blue" {
  count                      = var.number_of_session_hosts
  name                       = "${var.prefix_blue}${count.index + 1}-avd_blue_dsc"
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_blue_sh_vm.*.id[count.index]
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.73"
  auto_upgrade_minor_version = true
  depends_on = [ azurerm_windows_virtual_machine.avd_blue_sh_vm ]

  settings = <<-SETTINGS
    {
      "modulesUrl": "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_09-08-2022.zip",
      "configurationFunction": "Configuration.ps1\\AddSessionHost",
      "properties": {
        "HostPoolName":"${azurerm_virtual_desktop_host_pool.hostpool_blue.name}",
        "aadJoin": true
      }
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
    "properties": {
      "registrationInfoToken": "${local.registration_token_blue}"
    }
  }
PROTECTED_SETTINGS
}

resource "azurerm_virtual_machine_extension" "vmext_dsc_green" {
  count                      = var.number_of_session_hosts
  name                       = "${var.prefix_green}${count.index + 1}-avd_green_dsc"
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_green_sh_vm.*.id[count.index]
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.73"
  auto_upgrade_minor_version = true
  depends_on = [ azurerm_windows_virtual_machine.avd_green_sh_vm ]

  settings = <<-SETTINGS
    {
      "modulesUrl": "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_09-08-2022.zip",
      "configurationFunction": "Configuration.ps1\\AddSessionHost",
      "properties": {
        "HostPoolName":"${azurerm_virtual_desktop_host_pool.hostpool_green.name}",
        "aadJoin": true
      }
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
    "properties": {
      "registrationInfoToken": "${local.registration_token_green}"
    }
  }
PROTECTED_SETTINGS
}
