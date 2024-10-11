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

variable "westus_ag_subnet" {
  type = string
  description = "west us appgw subnet"
}

variable "westeu_ag_subnet" {
  type = string
  description = "west eu appgw subnet"
}

variable "westus_subnets" {
  type = map(string)
  description = "West US VNet Object"
}

variable "westeu_subnets" {
  type = map(string)
  description = "West Europe VNet Object"
}

variable "westus_vnet" {
  type = string
  description = "vnet 1 id"
}
variable "westeurope_vnet" {
  type = string
  description = "vnet 2 id"
}


locals {
  nic_definitions = {
    # Group NICs for West US into a local variable
    westus_nics1 = {
      westus_nic_vm1 = var.network_interface_ids.westus_vm1,
      westus_nic_vm2 = var.network_interface_ids.westus_vm2,
    },
    # Group NICs for West Europe into a local variable
    westeu_nics2 = {
      westeu_nic_vm1 = var.network_interface_ids.westeu_vm1,
      westeu_nic_vm2 = var.network_interface_ids.westeu_vm2,
    }
  }
}

# Public IP for West US Load Balancer
resource "azurerm_public_ip" "westus_lb_pip" {
  name                = "${var.student_id}-dc-wus-lb-pip"
  resource_group_name = var.resource_groups["region1"].name
  location            = var.resource_groups["region1"].location
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "dc-westus-lbalancer"
}

# Public IP for West Europe Load Balancer
resource "azurerm_public_ip" "westeu_lb_pip" {
  name                = "${var.student_id}-dc-weu-lb-pip"
  resource_group_name = var.resource_groups["region2"].name
  location            = var.resource_groups["region2"].location
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "dc-westeu-lbalancer"
}

# Load Balancer for West US
resource "azurerm_lb" "westus_lb" {
  name                = "${var.student_id}-wus-lb"
  location            = var.resource_groups["region1"].location
  resource_group_name = var.resource_groups["region1"].name
  sku                 = "Standard"
  frontend_ip_configuration {
    name                 = "westus-frontend"
    public_ip_address_id = azurerm_public_ip.westus_lb_pip.id
  }
}

# Load Balancer for West Europe
resource "azurerm_lb" "westeu_lb" {
  name                = "${var.student_id}-weu-lb"
  location            = var.resource_groups["region2"].location
  resource_group_name = var.resource_groups["region2"].name
  sku                 = "Standard"
  frontend_ip_configuration {
    name                 = "westeu-frontend"
    public_ip_address_id = azurerm_public_ip.westeu_lb_pip.id
  }
}

# Health Probe for West US Load Balancer
resource "azurerm_lb_probe" "westus_probe" {
  name                = "${var.student_id}-wus-probe"
  loadbalancer_id     = azurerm_lb.westus_lb.id
  protocol            = "Http"
  port                = 80
  request_path = "/"
  interval_in_seconds = 5
  number_of_probes = 2
}

# Health Probe for West Europe Load Balancer
resource "azurerm_lb_probe" "westeu_probe" {
  name                = "${var.student_id}-weu-probe"
  loadbalancer_id     = azurerm_lb.westeu_lb.id
  protocol            = "Http"
  port                = 80
  request_path = "/"
  interval_in_seconds = 5
  number_of_probes = 2
}

# Load balancing rule for west US
resource "azurerm_lb_rule" "westus_rule" {
  name                           = "${var.student_id}-westus-rule-tcp"
  loadbalancer_id                = azurerm_lb.westus_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "westus-frontend"
  disable_outbound_snat = true
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.westus_backend.id]
  probe_id                       = azurerm_lb_probe.westus_probe.id
}

# Load balancing rule for west eu
resource "azurerm_lb_rule" "westeu_rule" {
  name                           = "${var.student_id}-westeu-rule-tcp"
  loadbalancer_id                = azurerm_lb.westeu_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "westeu-frontend"
  disable_outbound_snat = true
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.westeurope_backend.id]
  probe_id                       = azurerm_lb_probe.westeu_probe.id
}


# Backend Pool for West US Load Balancer
resource "azurerm_lb_backend_address_pool" "westus_backend" {
  name                = "westus-backendpool"
  loadbalancer_id     = azurerm_lb.westus_lb.id
}

# Backend Pool for West Europe Load Balancer
resource "azurerm_lb_backend_address_pool" "westeurope_backend" {
  name                = "westeu-backendpool"
  loadbalancer_id     = azurerm_lb.westeu_lb.id
}

# Outbound rule for west us
resource "azurerm_lb_outbound_rule" "westus_outbound_rule" {
  loadbalancer_id                  = azurerm_lb.westus_lb.id
  name                             = "${var.student_id}-westus-outbound-rule"
  backend_address_pool_id          = azurerm_lb_backend_address_pool.westus_backend.id
  protocol                         = "Tcp"
  
  frontend_ip_configuration {
    name = "westus-frontend"
  }
}

# Outbound rule for west europe
resource "azurerm_lb_outbound_rule" "westeu_outbound_rule" {
  loadbalancer_id                  = azurerm_lb.westeu_lb.id
  name                             = "${var.student_id}-westeu-outbound-rule"
  backend_address_pool_id          = azurerm_lb_backend_address_pool.westeurope_backend.id
  protocol                         = "Tcp"
  frontend_ip_configuration {
    name = "westeu-frontend"
  }
}


# Network Interface to Backend Pool Association for West US Load Balancer
resource "azurerm_network_interface_backend_address_pool_association" "westus_nic_lb" {
  for_each                = local.nic_definitions.westus_nics1
  network_interface_id    = each.value
  backend_address_pool_id = azurerm_lb_backend_address_pool.westus_backend.id
  ip_configuration_name   = "${var.student_id}-wu-ipconfig${index(keys(local.nic_definitions.westus_nics1), each.key) + 1}"
  depends_on              = [azurerm_lb_backend_address_pool.westus_backend]
}

# Network Interface to Backend Pool Association for West Europe Load Balancer
resource "azurerm_network_interface_backend_address_pool_association" "westeurope_nic_lb" {
  for_each                = local.nic_definitions.westeu_nics2
  network_interface_id    = each.value
  backend_address_pool_id = azurerm_lb_backend_address_pool.westeurope_backend.id
  ip_configuration_name   = "${var.student_id}-we-ipconfig${index(keys(local.nic_definitions.westeu_nics2), each.key) + 1}"

  depends_on              = [azurerm_lb_backend_address_pool.westeurope_backend] 
}

# Traffic Manager Profile
resource "azurerm_traffic_manager_profile" "traffic_manager" {
  name                = "${var.student_id}-dctm"  
  resource_group_name = var.resource_groups["region3"].name # central region
  traffic_routing_method = "Performance"

  dns_config {
    relative_name = "${var.student_id}-dctm"
    ttl           = 100
  }

  monitor_config {
    protocol                     = "HTTP"
    port                         = 80
    path = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }

}

# Endpoint for Application in West US Connected Traffic Manager
resource "azurerm_traffic_manager_azure_endpoint" "westus_endpoint" {
  name                    = "${var.student_id}-westus-lb"  # Including Student ID
  profile_id              = azurerm_traffic_manager_profile.traffic_manager.id
  target_resource_id      = azurerm_public_ip.westus_lb_pip.id 
  priority                = 1
  # depends_on              = [azurerm_application_gateway.westus_appgw]
}

# Endpoint for Load Balancer in West US Connected Traffic Manager
resource "azurerm_traffic_manager_azure_endpoint" "westeurope_endpoint" {
  name                    = "${var.student_id}-westeu-lb"  # Including Student ID
  profile_id              = azurerm_traffic_manager_profile.traffic_manager.id
  target_resource_id      = azurerm_public_ip.westeu_lb_pip.id  
  priority                = 2
  # depends_on              = [azurerm_application_gateway.westeu_appgw]
}

# Private DNS Zone for Traffic Manager
resource "azurerm_private_dns_zone" "app_dns" {
  name                = "dchiatuiro.com"
  resource_group_name = var.resource_groups["region3"].name
}

# Private DNS CNAME Record
resource "azurerm_private_dns_cname_record" "app_cname_record" {
  name                = "www"
  zone_name           = azurerm_private_dns_zone.app_dns.name
  resource_group_name = var.resource_groups["region3"].name
  ttl                 = 300
  record              = azurerm_traffic_manager_profile.traffic_manager.fqdn  # Traffic Manager FQDN
}

# Link Private DNS Zone to VNET (Ensure VNET is defined in your config)
resource "azurerm_private_dns_zone_virtual_network_link" "vnet1_dns_link" {
  name                  = "${var.student_id}-wus-dns-link"
  resource_group_name   = var.resource_groups["region3"].name
  private_dns_zone_name = azurerm_private_dns_zone.app_dns.name
  virtual_network_id    = var.westus_vnet
  registration_enabled  = false  # Disable automatic registration
}
# Link Private DNS Zone to VNET (Ensure VNET is defined in your config)
resource "azurerm_private_dns_zone_virtual_network_link" "vnet2_dns_link" {
  name                  = "${var.student_id}-weu-dns-link"
  resource_group_name   = var.resource_groups["region3"].name
  private_dns_zone_name = azurerm_private_dns_zone.app_dns.name
  virtual_network_id    = var.westeurope_vnet
  registration_enabled  = false  # Disable automatic registration
}