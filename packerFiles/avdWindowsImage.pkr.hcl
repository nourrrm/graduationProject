# Defining required plugins
packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "2.0.1"
    }

    windows-update = {
      version = "0.14.3"
      source  = "github.com/rgl/windows-update"
    }
  }
}

source "azure-arm" "windowsBasicAvdImage" {
  # Azure credentials for communication with Azure
  client_id       = var.client_id
  client_secret   = var.client_secret
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id

  # Setting up the shared image gallery and WinRM communicator
  shared_image_gallery {
    subscription   = var.subscription_id
    resource_group = var.rg_name
    image_name     = var.gallery_image_name
    image_version  = var.current_gallery_image_version
  }

  shared_image_gallery_destination {
    subscription         = var.subscription_id
    resource_group       = var.rg_name
    gallery_name         = var.gallery_name
    image_name           = var.gallery_image_name
    image_version        = var.new_gallery_image_version
    storage_account_type = var.storage_account_type
  }

  communicator   = "winrm"
  winrm_username = var.windows_vm_user
  winrm_password = var.windows_vm_pw
  winrm_use_ssl  = true
  winrm_insecure = true
  winrm_timeout  = "10m"

  # Azure resource group and AVD image
  location        = var.location
  os_type         = var.os_type
  image_publisher = var.image_publisher_name
  image_offer     = var.image_offer
  image_sku       = var.image_sku
  vm_size         = var.vm_size

}

#Building the image and provisioning it to the Shared Image Gallery
build {
  sources = ["source.azure-arm.windowsBasicAvdImage"]

  #Windows provisioner to lookup Windows updates and install them on the image
  provisioner "windows-update" {
    search_criteria = "IsInstalled=0"
    filters = [
      "exclude:$_.Title -like '*Preview*'",
      "include:$true",
    ]
    update_limit = 20
  }

  #PowerShell provisioner for sysprepping the image
  provisioner "powershell" {
    script = "sysprepFile.ps1"
  }
}
