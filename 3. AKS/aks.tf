# Nota: data "azurerm_subnet" "aks" se define en data-network.tf

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.aks_name

  # Identity SystemAssigned requerido
  identity {
    type = "SystemAssigned"
  }

  # Pool del sistema: conectado a la Subnet existente (Azure CNI)
  default_node_pool {
    name           = "system"
    vm_size        = "Standard_B2as_v2"
    node_count     = 1
    vnet_subnet_id = data.azurerm_subnet.aks.id
    type           = "VirtualMachineScaleSets"
    # Si te quedas sin IPs, baja max_pods (ej. 30)
    # max_pods = 30
  }

  # Azure CNI para que pods reciban IPs del subnet
  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    network_policy    = "calico"
    # outbound_type = "userDefinedRouting" # opcional si usas UDR/FW
  }

  role_based_access_control_enabled = true
  oidc_issuer_enabled               = true
  workload_identity_enabled         = true
  depends_on                        = []
}

data "azurerm_client_config" "current" {}

data "azurerm_role_definition" "network_contributor" {
  name  = "Network Contributor"
  scope = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
}

resource "azurerm_role_assignment" "aks_netcontrib_on_subnet" {
  scope              = data.azurerm_subnet.aks.id
  role_definition_id = data.azurerm_role_definition.network_contributor.role_definition_id
  principal_id       = azurerm_kubernetes_cluster.aks.identity[0].principal_id

  depends_on = [azurerm_kubernetes_cluster.aks]
}