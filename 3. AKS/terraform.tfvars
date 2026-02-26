resource_group_name = "rg-cloud-lab"
vnet_name           = "vnet-e08"
subnet_name         = "snet-e08"
aks_name            = "aks-e08"
location            = "eastus"

tags = {
  owner      = "erick.iza"
  managed-by = "terraform"
  env        = "lab"
}
