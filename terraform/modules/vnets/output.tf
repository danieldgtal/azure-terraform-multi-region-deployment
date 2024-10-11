# Output subnet for west us vnet
output "westus_subnet" {
  value = {
    westus_subnet = azurerm_subnet.westus_subnet.id
  }
}

# Output subnet for west europe vnet
output "westeu_subnet" {
  value = {
    westeu_subnet = azurerm_subnet.westeu_subnet.id
  }
}

# Output subnet for west application gateway
output "westus_ag_subnet" {
  value = azurerm_subnet.westus_ag_subnet.id
}

# Output subenet for west europe application gateway
output "westeu_ag_subnet" {
  value = azurerm_subnet.westeu_ag_subnet.id
}
# Output the Vnet US
output "westus_vnet" {
  value = azurerm_virtual_network.westus_vnet.id
}

# oUTPUT the Vnet Europe
output "westeurope_vnet" {
  value = azurerm_virtual_network.westeurope_vnet.id
}

# Outputs for Nic 
output "nic_ids" {
  value = {
    westus_vm1 = azurerm_network_interface.westus_nic_vm1.id,
    westus_vm2 = azurerm_network_interface.westus_nic_vm2.id, 
    westeu_vm1 = azurerm_network_interface.westeu_nic_vm1.id,
    westeu_vm2 = azurerm_network_interface.westeu_nic_vm2.id,
    westus_pc1 = azurerm_network_interface.westus_nic_pc1.id,
    westeu_pc1 = azurerm_network_interface.westeu_nic_pc2.id,
  }
  description = "List of NIC IDs for the VMs in key, value object"
}
