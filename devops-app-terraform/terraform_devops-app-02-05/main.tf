data "azurerm_resource_group" "RG" {
  name = "${var.RG_name}"
}

data "azurerm_virtual_network" "Network" {
  name = "${var.Network_name}"
  resource_group_name = "${data.azurerm_resource_group.RG.name}"
}

data "azurerm_subnet" "Subnet" {
  name = "${var.Subnet_name}"
  resource_group_name = "${data.azurerm_resource_group.RG.name}"
  virtual_network_name = "${data.azurerm_virtual_network.Network.name}"
}

data "azurerm_storage_account" "storage_account" {
  name = "diageb1d62b6233fc336"
  resource_group_name = "${data.azurerm_resource_group.RG.name}"
}