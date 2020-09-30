resource "azurerm_resource_group" "RG" {
   name = "${var.RG_name}"
   location = "${var.location}"
   tags {
      environment = "${var.tag}"
   }
}

resource "azurerm_virtual_network" "Network" {
   name = "${var.Network_name}"
   address_space = ["${var.address_space}"]
   location = "${var.location}"
   resource_group_name = "${azurerm_resource_group.RG.name}"
   tags {
      environment = "${var.tag}"
   }
}

resource "azurerm_subnet" "Subnet" {
   name = "${var.Subnet_name}"
   resource_group_name = "${azurerm_resource_group.RG.name}"
   virtual_network_name = "${azurerm_virtual_network.Network.name}"
   address_prefix = "${var.Subnet_address_prefix}"
}

resource "random_id" "randomId" {
   keepers = {
      # Generate a new ID only when a new resource group is defined
      resource_group = "${azurerm_resource_group.RG.name}"
   }
   byte_length = 8
}

resource "azurerm_storage_account" "StorageAccount" {
   name = "diag${random_id.randomId.hex}"
   resource_group_name = "${azurerm_resource_group.RG.name}"
   location = "${var.location}"
   account_replication_type = "${lookup(var.StorageAccount, "account_replication_type")}"
   account_tier = "${lookup(var.StorageAccount, "account_tier")}"
   tags {
      environment = "${var.tag}"
   }
}