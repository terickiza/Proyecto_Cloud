resource_group_name   = "rg-cloud-lab"
vnet_e08              = "vnet-e08"
vnet_e8_address_space = ["10.58.0.0/16"]
subnet_e08            = "snet-e08"
subnet_e8_prefix      = "10.58.1.0/24"

tags = {
  owner      = "erick.iza"
  managed-by = "terraform"
  env        = "lab"
}
