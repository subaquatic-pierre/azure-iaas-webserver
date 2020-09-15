provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-rg"
  location = var.location

  tags = {
    udacity = "${var.prefix}-project-1"
  }

}

// Main virtual network, subnets, nics and public IPs

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    udacity = "${var.prefix}-project-1"
  }

}

resource "azurerm_subnet" "internal" {
  name                 = "${var.prefix}-internal-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.0.0/16"]
}

resource "azurerm_public_ip" "pip" {
  name                = "${var.prefix}-public-ip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Dynamic"

  tags = {
    udacity = "${var.prefix}-project-1"
  }
}

resource "azurerm_network_interface" "main" {
  count               = var.instance_count
  name                = "${var.prefix}-nic-${count.index}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "${var.prefix}-primary"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    udacity = "${var.prefix}-project-1"
  }
}

// Secutiy Group

resource "azurerm_network_security_group" "webserver" {
  name                = "${var.prefix}-webserver-sg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "${var.prefix}-allow-internal"
    priority                   = 100
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = azurerm_subnet.internal.address_prefix
    destination_port_range     = "*"
    destination_address_prefix = azurerm_subnet.internal.address_prefix
  }

  security_rule {
    access                     = "Deny"
    direction                  = "Inbound"
    name                       = "${var.prefix}-block-external"
    priority                   = 101
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "*"
    destination_address_prefix = azurerm_subnet.internal.address_prefix
  }

  tags = {
    udacity = "${var.prefix}-project-1"
  }
}

resource "azurerm_network_security_rule" "internal" {
  name                        = "internal-inbound-rule"
  resource_group_name         = "${azurerm_resource_group.main.name}"
  network_security_group_name = "${azurerm_network_security_group.webserver.name}"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "10.0.0.0/16"
  destination_address_prefix  = "10.0.0.0/16"
}

resource "azurerm_network_security_rule" "internal" {
  name                        = "internal-outbound-rule"
  resource_group_name         = "${azurerm_resource_group.main.name}"
  network_security_group_name = "${azurerm_network_security_group.webserver.name}"
  priority                    = 102
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "10.0.0.0/16"
  destination_address_prefix  = "10.0.0.0/16"
}

resource "azurerm_network_security_rule" "external" {
  name                        = "external-rule"
  resource_group_name         = "${azurerm_resource_group.main.name}"
  network_security_group_name = "${azurerm_network_security_group.webserver.name}"
  priority                    = 103
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

// Load balancer

resource "azurerm_lb" "main" {
  name                = "${var.prefix}-lb"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                 = "${var.prefix}-public-address"
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  tags = {
    udacity = "${var.prefix}-project-1"
  }
}

resource "azurerm_lb_backend_address_pool" "main" {
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.main.id
  name                = "${var.prefix}-backend-address-pool"
}

resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count                   = var.instance_count
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
  ip_configuration_name   = "${var.prefix}-primary"
  network_interface_id    = element(azurerm_network_interface.main.*.id, count.index)
}

resource "azurerm_availability_set" "avset" {
  name                = "${var.prefix}-avset"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    udacity = "${var.prefix}-project-1"
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  count                           = var.instance_count
  name                            = "${var.prefix}-vm-${count.index}"
  resource_group_name             = azurerm_resource_group.main.name
  source_image_id                 = var.image_id
  location                        = azurerm_resource_group.main.location
  size                            = "Standard_D3_v2"
  admin_username                  = var.username
  admin_password                  = var.password
  availability_set_id             = azurerm_availability_set.avset.id
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.main[count.index].id,
  ]

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  tags = {
    udacity = "${var.prefix}-project-1"
  }
}
