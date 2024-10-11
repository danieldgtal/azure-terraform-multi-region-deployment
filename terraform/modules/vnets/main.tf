# Define variable for resource group map
variable "resource_groups" {
  type = map(object({
    name     = string
    location = string
  }))
  description = "Map of resource group names and locations"
}

# Virtual Network for West US Region
resource "azurerm_virtual_network" "westus_vnet" {
  name                = "${var.student_id}-westus-vnet"
  location            = var.resource_groups["region1"].location
  resource_group_name = var.resource_groups["region1"].name
  address_space       = ["172.16.100.0/24"]  # allocated IP CIDR
}

# Virtual Network for West Europe Region
resource "azurerm_virtual_network" "westeurope_vnet" {
  name                = "${var.student_id}-westeurope-vnet"
  location            = var.resource_groups["region2"].location
  resource_group_name = var.resource_groups["region2"].name
  address_space       = ["172.16.100.0/24"]  # Assigned CIDR
}

# Create subnet for West US region
resource "azurerm_subnet" "westus_subnet" {
  name = "${var.student_id}-westus-subnet"
  resource_group_name = var.resource_groups["region1"].name
  virtual_network_name = azurerm_virtual_network.westus_vnet.name
  address_prefixes = ["172.16.100.0/28"]  # Changed to /28 for 14 usable IPs
}

# Create Bastion subnet for West US region
resource "azurerm_subnet" "westus_bastion_subnet" {
  name = "AzureBastionSubnet"
  resource_group_name = var.resource_groups["region1"].name
  virtual_network_name = azurerm_virtual_network.westus_vnet.name
  address_prefixes = ["172.16.100.16/28"]  # Changed to /28 for Bastion subnet
}

# Create subnet for Application Gateway in West US region
resource "azurerm_subnet" "westus_ag_subnet" {
  name = "${var.student_id}-westus-ag-subnet"
  resource_group_name = var.resource_groups["region1"].name
  virtual_network_name = azurerm_virtual_network.westus_vnet.name
  address_prefixes = ["172.16.100.32/28"]  # Changed to /28 for App Gateway
}

# Create subnet for West Europe region
resource "azurerm_subnet" "westeu_subnet" {
  name = "${var.student_id}-westeu-subnet"
  resource_group_name = var.resource_groups["region2"].name
  virtual_network_name = azurerm_virtual_network.westeurope_vnet.name
  address_prefixes = ["172.16.100.48/28"]  # Changed to /28 for 14 usable IPs
}

# Create Bastion subnet for West Europe region
resource "azurerm_subnet" "westeu_bastion_subnet" {
  name = "AzureBastionSubnet"
  resource_group_name = var.resource_groups["region2"].name
  virtual_network_name = azurerm_virtual_network.westeurope_vnet.name
  address_prefixes = ["172.16.100.64/28"]  # Changed to /28 for Bastion subnet
}

# Create subnet for Application Gateway in West Europe region
resource "azurerm_subnet" "westeu_ag_subnet" {
  name = "${var.student_id}-westeu-ag-subnet"
  resource_group_name = var.resource_groups["region2"].name
  virtual_network_name = azurerm_virtual_network.westeurope_vnet.name
  address_prefixes = ["172.16.100.80/28"]  # Changed to /28 for App Gateway
}

# Define a Network security group for the west us rgion
resource "azurerm_network_security_group" "westus_nsg" {
  name = "${var.student_id}-westus-nsg"
  location = var.resource_groups["region1"].location
  resource_group_name = var.resource_groups["region1"].name

  security_rule {
    name                       = "RDP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "web"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

# Define a Network security group for the west europe rgion
resource "azurerm_network_security_group" "westeu_nsg" {
  name = "${var.student_id}-westeu-nsg"
  location = var.resource_groups["region2"].location
  resource_group_name = var.resource_groups["region2"].name

  security_rule {
    name                       = "RDP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "web"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

# NIC for VM1 in West US
resource "azurerm_network_interface" "westus_nic_vm1" {
  name = "${var.student_id}-westus-nic-vm1"
  location = var.resource_groups["region1"].location
  resource_group_name = var.resource_groups["region1"].name

  ip_configuration {
    name =  "${var.student_id}-wu-ipconfig1"
    subnet_id = azurerm_subnet.westus_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
# Connect the security group to the network interface of VM1 of West US
resource "azurerm_network_interface_security_group_association" "westus_nic_vm1_nsg_ass" {
  network_interface_id = azurerm_network_interface.westus_nic_vm1.id
  network_security_group_id = azurerm_network_security_group.westus_nsg.id
}


# NIC for VM2 in West US
resource "azurerm_network_interface" "westus_nic_vm2" {
  name = "${var.student_id}-westus-nic-vm2"
  location = var.resource_groups["region1"].location
  resource_group_name = var.resource_groups["region1"].name

  ip_configuration {
    name =  "${var.student_id}-wu-ipconfig2"
    subnet_id = azurerm_subnet.westus_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
# Connect the security group to the network interface of VM1 of West US
resource "azurerm_network_interface_security_group_association" "westus_nic_vm2_nsg_ass" {
  network_interface_id = azurerm_network_interface.westus_nic_vm2.id
  network_security_group_id = azurerm_network_security_group.westus_nsg.id
}


# Create network interface EU VM 1
resource "azurerm_network_interface" "westeu_nic_vm1" {
  name = "${var.student_id}-westeu-nic-vm1"
  location = var.resource_groups["region2"].location
  resource_group_name = var.resource_groups["region2"].name

  ip_configuration {
    name =  "${var.student_id}-we-ipconfig1"
    subnet_id = azurerm_subnet.westeu_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
# Connect the security group to the network interface of VM1
resource "azurerm_network_interface_security_group_association" "westeu_nic_vm1_nsg_ass" {
  network_interface_id = azurerm_network_interface.westeu_nic_vm1.id
  network_security_group_id = azurerm_network_security_group.westeu_nsg.id
}

# Create network interface EU VM 2
resource "azurerm_network_interface" "westeu_nic_vm2" {
  name = "${var.student_id}-westeu-nic-vm2"
  location = var.resource_groups["region2"].location
  resource_group_name = var.resource_groups["region2"].name

  ip_configuration {
    name =  "${var.student_id}-we-ipconfig2"
    subnet_id = azurerm_subnet.westeu_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "westeu_nic_vm2_nsg_ass" {
  network_interface_id = azurerm_network_interface.westeu_nic_vm2.id
  network_security_group_id = azurerm_network_security_group.westeu_nsg.id
}

# Create a network interface West US PC1
resource "azurerm_network_interface" "westus_nic_pc1" {
  name = "${var.student_id}-westus-nic-pc1"
  location = var.resource_groups["region1"].location
  resource_group_name = var.resource_groups["region1"].name

  ip_configuration {
    name =  "ipconfig1"
    subnet_id = azurerm_subnet.westus_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Connect and associate the nic with security group
resource "azurerm_network_interface_security_group_association" "westus_nic_pc1_nsg_ass" {
  network_interface_id = azurerm_network_interface.westus_nic_pc1.id
  network_security_group_id = azurerm_network_security_group.westus_nsg.id
}

# Create a network interface West US PC1
resource "azurerm_network_interface" "westeu_nic_pc2" {
  name = "${var.student_id}-westeu-nic-pc2"
  location = var.resource_groups["region2"].location
  resource_group_name = var.resource_groups["region2"].name

  ip_configuration {
    name =  "ipconfig2"
    subnet_id = azurerm_subnet.westeu_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Connect and associate the nic with security group
resource "azurerm_network_interface_security_group_association" "westeu_nic_pc2_nsg_ass" {
  network_interface_id = azurerm_network_interface.westeu_nic_pc2.id
  network_security_group_id = azurerm_network_security_group.westeu_nsg.id
}

# Bastion for Logging into the VMS through Private IP address
resource "azurerm_public_ip" "bastion_ip_westus" {
  name                = "westus-bastion-pip"
  resource_group_name = var.resource_groups["region1"].name
  location            = var.resource_groups["region1"].location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "bastion_ip_westeurope" {
  name                = "westeurope-bastion-pip"
  resource_group_name = var.resource_groups["region2"].name
  location            = var.resource_groups["region2"].location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Bastion Host for West US
resource "azurerm_bastion_host" "westus_bastion" {
  name                = "${var.student_id}-westus-bastion"
  location            = var.resource_groups["region1"].location
  resource_group_name = var.resource_groups["region1"].name
  # dns_name            = "westusbastion" # Optional for FQDN To be added later

  ip_configuration {
    name                 = "bastion-config"
    subnet_id            = azurerm_subnet.westus_bastion_subnet.id # Use the subnet ID from your existing VNet
    public_ip_address_id = azurerm_public_ip.bastion_ip_westus.id
  }
}

# Bastion Host for West Europe
resource "azurerm_bastion_host" "westeurope_bastion" {
  name                = "${var.student_id}-westeu-bastion"
  location            = var.resource_groups["region2"].location
  resource_group_name = var.resource_groups["region2"].name
  # dns_name            = "westeuropebastion" # Optional for FQDN

  ip_configuration {
    name                 = "bastion-config"
    subnet_id            = azurerm_subnet.westeu_bastion_subnet.id # Use the subnet ID from your existing VNet
    public_ip_address_id = azurerm_public_ip.bastion_ip_westeurope.id
  }
}

