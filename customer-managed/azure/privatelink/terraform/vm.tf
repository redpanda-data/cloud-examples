locals {
  vm_user_data_with_cloud_config_directive = "#cloud-config\n${jsonencode(local.vm_user_data)}"
}


resource "azurerm_network_interface" "consumer_vm" {
  name                = "${var.resource_prefix}_consumer_vm_nic"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_public_ip" "public_ip" {
  name                = "${var.resource_prefix}_publicip"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static" # Use "Dynamic" if you want a dynamic IP address

  tags = {
    environment = "sandbox"
  }
}

resource "azurerm_network_security_group" "ssh-nsg" {
  name                = "${var.resource_prefix}_ssh_nsg"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "association" {
  network_interface_id      = azurerm_network_interface.consumer_vm.id
  network_security_group_id = azurerm_network_security_group.ssh-nsg.id
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.key.private_key_pem
  filename        = "${path.module}/private_key.pem"
  file_permission = "0600"
}

resource "azurerm_linux_virtual_machine" "consumer-vm" {
  name                  = "${var.resource_prefix}-redpanda-vm"
  location              = var.region
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.consumer_vm.id]
  size                  = "Standard_DS1_v2"
  admin_username        = "redpanda"
  admin_ssh_key {
    username   = "redpanda"                                        # Replace with your desired admin username
    public_key = trimspace(tls_private_key.key.public_key_openssh) # Path to your SSH public key file
  }


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(local.vm_user_data_with_cloud_config_directive)
}

