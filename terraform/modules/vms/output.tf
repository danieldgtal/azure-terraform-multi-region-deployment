# Output for the dynamically created VMs
output "vms" {
  value = {
    for vm in azurerm_windows_virtual_machine.vm : vm.name => {
      name                 = vm.name
      id                   = vm.id
      network_interface_ids = vm.network_interface_ids
      resource_group        = vm.resource_group_name
    }
  }
  description = "Details of the dynamically created VMs"
}
