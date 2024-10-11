# Define variable for resource group map
variable "resource_groups" {
  type = map(object({
    name     = string
    location = string
  }))
  description = "Map of resource group names and locations"
}


variable "network_interface_ids" {
  type = map(string)
  description = "List of network IDs for the VMs"
}

# Windows Server Variable
locals {
  vm_definitions = {
    "westus_vm1" = {
      name                 = "${var.student_id}-wu1", # wu = West US, 1 = VM1
      location             = var.resource_groups["region1"].location
      resource_group_name  = var.resource_groups["region1"].name
      network_interface_id = var.network_interface_ids.westus_vm1,
    },
    "westus_vm2" = {
      name                 = "${var.student_id}-wu2",
      location             = var.resource_groups["region1"].location
      resource_group_name  = var.resource_groups["region1"].name
      network_interface_id = var.network_interface_ids.westus_vm2,
    },
    "westeu_vm1" = {
      name                 = "${var.student_id}-we1",  # wu = West Europe, 1 = VM1
      location             = var.resource_groups["region2"].location
      resource_group_name  = var.resource_groups["region2"].name
      network_interface_id = var.network_interface_ids.westeu_vm1,
    },
     "westeu_vm2" = {
      name                 = "${var.student_id}-we2",
      location             = var.resource_groups["region2"].location
      resource_group_name  = var.resource_groups["region2"].name
      network_interface_id = var.network_interface_ids.westeu_vm2,
    }
  }
}

# Window PC Variable
locals {
  pc_definitions = {
    "westus_pc" = {
      name = "${var.student_id}-pc1",
      location = var.resource_groups["region1"].location,
      resource_group_name = var.resource_groups["region1"].name
      network_interface_id = var.network_interface_ids.westus_pc1
    },
    "westeu_pc" = {
      name = "${var.student_id}-pc2",
      location = var.resource_groups["region2"].location,
      resource_group_name = var.resource_groups["region2"].name
      network_interface_id = var.network_interface_ids.westeu_pc1
    }
  }
}

# Dynamically create VMs using for_each
resource "azurerm_windows_virtual_machine" "vm" {
  for_each            = local.vm_definitions
  name                = each.value.name
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  network_interface_ids = [each.value.network_interface_id]
  size                = var.vm_size

  os_disk {
    caching             = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}


# Dynamically create Client VM
resource "azurerm_windows_virtual_machine" "pc" {
  for_each            = local.pc_definitions
  name                = each.value.name
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  network_interface_ids = [each.value.network_interface_id]
  size                = var.vm_size  # Or adjust based on your requirements

  os_disk {
    name                = "${each.value.name}-disk"
    caching             = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = "win11-21h2-pro"
    version   = "latest"
  }
}


# VM lock on all VM webservers
resource "azurerm_management_lock" "do_not_delete_lock_servers" {
  for_each = local.vm_definitions
  name               = "${each.value.name}-lock"
  lock_level        = "CanNotDelete"
  scope = azurerm_windows_virtual_machine.vm[each.key].id
}


# VM lock on all VM client pc
resource "azurerm_management_lock" "do_not_delete_lock_pc" {
  for_each = local.pc_definitions
  name               = "${each.value.name}-lock"
  lock_level        = "CanNotDelete"
  scope = azurerm_windows_virtual_machine.pc[each.key].id
}
