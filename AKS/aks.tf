resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks-e08
  location            = var.location
  resource_group_name = var.rg-cloud-lab
  dns_prefix          = var.aks-e08

  # Usamos permisos en la Subnet
  identity {
    type = "SystemAssigned"
  }

  # Pool del sistema: "colgado" a la Subnet EXISTENTE
  default_node_pool {
    name           = "system"
    vm_size        = "Standard_D2s_v5"
    node_count     = 1
    vnet_subnet_id = data.azurerm_subnet.aks.id
    type           = "VirtualMachineScaleSets"
    # Opcional: si temes quedarte sin IPs, baja el max_pods p.ej. a 30
    # max_pods    = 30
  }

  # Red: Azure CNI (pods con IP del subnet). Requiere planificación de IPs.
  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    network_policy    = "calico" # o "calico"
    # outbound_type   = "userDefinedRouting" # si tu egress pasa por FW/NVA con UDR
  }

  # Recomendado para integraciones modernas
  role_based_access_control_enabled = true
  oidc_issuer_enabled               = true
  workload_identity_enabled         = true

  # depends_on = [
  #   azurerm_role_assignment.uami_netcontrib_on_subnet
  # ]
}