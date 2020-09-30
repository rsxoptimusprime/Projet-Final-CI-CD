resource "azurerm_virtual_network" "Networkextra" {
   name = "${var.Network_name}extra"
   address_space = ["${var.address_space}"]
   location = "${var.location2}"
   resource_group_name = "${data.azurerm_resource_group.RG.name}"
   tags {
      environment = "${var.tag}"
   }
}

resource "azurerm_subnet" "Subnetextra" {
   name = "${var.Subnet_name}extra"
   resource_group_name = "${data.azurerm_resource_group.RG.name}"
   virtual_network_name = "${azurerm_virtual_network.Networkextra.name}"
   address_prefix = "${var.Subnet_address_prefix}"
}

resource "random_id" "randomIdextra" {
   keepers = {
      # Generate a new ID only when a new resource group is defined
      resource_group_name = "${data.azurerm_resource_group.RG.name}"
   }
   byte_length = 8
}

resource "azurerm_storage_account" "StorageAccountextra" {
   name = "diag${random_id.randomIdextra.hex}"
   resource_group_name = "${data.azurerm_resource_group.RG.name}"
   location = "${var.location2}"
   account_replication_type = "${lookup(var.StorageAccount, "account_replication_type")}"
   account_tier = "${lookup(var.StorageAccount, "account_tier")}"
   tags {
      environment = "${var.tag}"
   }
}

resource "azurerm_public_ip" "PublicIPextra" {
   name = "${var.PublicIP_name}extra"
   location = "${var.location2}"
   resource_group_name = "${data.azurerm_resource_group.RG.name}"
   public_ip_address_allocation = "${var.address_allocation}"
   domain_name_label = "tomcat-pic"
   tags {
      environment = "${var.tag}"
   }
}

resource "azurerm_network_security_group" "NetworkSGextra" {
   name = "${var.NSG_name}extra"
   location = "${var.location2}"
   resource_group_name = "${data.azurerm_resource_group.RG.name}"
   tags {
      environment = "${var.tag}"
   }

   security_rule {
      name = "${lookup(var.NSG_rule, "name")}"
      priority = "${lookup(var.NSG_rule, "priority")}"
      direction = "${lookup(var.NSG_rule, "direction")}"
      access = "${lookup(var.NSG_rule, "access")}"
      protocol = "${lookup(var.NSG_rule, "protocol")}"
      source_port_range = "${lookup(var.NSG_rule, "source_port_range")}"
      destination_port_range = "${lookup(var.NSG_rule, "destination_port_range")}"
      source_address_prefix = "${lookup(var.NSG_rule, "source_address_prefix")}"
      destination_address_prefix = "${lookup(var.NSG_rule, "destination_address_prefix")}"
   }

   security_rule {
      name = "${lookup(var.NSG_Rule_HTTP, "name")}"
      priority = "${lookup(var.NSG_Rule_HTTP, "priority")}"
      direction = "${lookup(var.NSG_Rule_HTTP, "direction")}"
      access = "${lookup(var.NSG_Rule_HTTP, "access")}"
      protocol = "${lookup(var.NSG_Rule_HTTP, "protocol")}"
      source_port_range = "${lookup(var.NSG_Rule_HTTP, "source_port_range")}"
      destination_port_range = "${lookup(var.NSG_Rule_HTTP, "destination_port_range")}"
      source_address_prefix = "${lookup(var.NSG_Rule_HTTP, "source_address_prefix")}"
      destination_address_prefix = "${lookup(var.NSG_Rule_HTTP, "destination_address_prefix")}"
   }
}

resource "azurerm_network_interface" "NetworkInterfaceextra" {
   name = "${lookup(var.NetworkInterface, "name")}-05"
   location = "${var.location2}"
   resource_group_name = "${data.azurerm_resource_group.RG.name}"
   ip_configuration {
      name = "${lookup(var.NetworkInterface, "ip_configuration")}"
      subnet_id = "${azurerm_subnet.Subnetextra.id}"
      private_ip_address_allocation = "${lookup(var.NetworkInterface, "address_allocation")}"
      private_ip_address = "${lookup(var.Bastion, "private_ip")}"
      public_ip_address_id = "${azurerm_public_ip.PublicIPextra.id}"
   }
   network_security_group_id = "${azurerm_network_security_group.NetworkSGextra.id}"

   tags {
      environment = "${var.tag}"
   }
}

resource "azurerm_virtual_machine" "extra" {
   name = "devops-app-05"
   location = "${var.location2}"
   resource_group_name = "${data.azurerm_resource_group.RG.name}"
   network_interface_ids = ["${azurerm_network_interface.NetworkInterfaceextra.id}"]
   vm_size = "Standard_B2ms"

   storage_os_disk {
      name = "${lookup(var.storage_disk, "name")}-05"
      caching = "${lookup(var.storage_disk, "caching")}"
      create_option = "${lookup(var.storage_disk, "create_option")}"
      managed_disk_type = "${lookup(var.storage_disk, "managed_disk_type")}"
   }

   storage_image_reference {
      publisher = "${lookup(var.image_reference, "publisher")}"
      offer = "${lookup(var.image_reference, "offer")}"
      sku = "${lookup(var.image_reference, "sku")}"
      version = "${lookup(var.image_reference, "version")}"
   }

   os_profile {
      computer_name = "devops-app-05"
      admin_username = "${lookup(var.AVM, "admin_username")}"
   }

   os_profile_linux_config {
      disable_password_authentication = true
      ssh_keys {
         path = "/home/${lookup(var.AVM, "admin_username")}/.ssh/authorized_keys"
         key_data = "${file("id_rsa.pub")}"
      }
   }

   boot_diagnostics {
      enabled = "true"
      storage_uri = "${azurerm_storage_account.StorageAccountextra.primary_blob_endpoint}"
   }

   tags {
      environment = "${var.tag}"
   }
}
