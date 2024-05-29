# Graduation project
This the code for my graduation project. In this project I first used HashiCorp Packer to create a Windows image that installs Windows Security Updates and syspreps the VM before deploying the image as a shared image to the compute gallery.

With Terraform I have deployed the necessary Azure Virtual Desktop resources that uses the image I've created with Packer for the session hosts.
