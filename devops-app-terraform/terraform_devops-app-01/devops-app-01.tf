resource "azurerm_public_ip" "PublicIP" {
   name = "${var.PublicIP_name}"
   location = "${var.location}"
   resource_group_name = "${azurerm_resource_group.RG.name}"
   public_ip_address_allocation = "${var.address_allocation}"
   domain_name_label = "cloud-pic"
   tags {
      environment = "${var.tag}"
   }
}

resource "azurerm_network_security_group" "NetworkSG" {
   name = "${var.NSG_name}"
   location = "${var.location}"
   resource_group_name = "${azurerm_resource_group.RG.name}"
   tags {
      environment = "${var.tag}"
   }

   security_rule {
      name = "${lookup(var.SSH_rule, "name")}"
      priority = "${lookup(var.SSH_rule, "priority")}"
      direction = "${lookup(var.SSH_rule, "direction")}"
      access = "${lookup(var.SSH_rule, "access")}"
      protocol = "${lookup(var.SSH_rule, "protocol")}"
      source_port_range = "${lookup(var.SSH_rule, "source_port_range")}"
      destination_port_range = "${lookup(var.SSH_rule, "destination_port_range")}"
      source_address_prefix = "${lookup(var.SSH_rule, "source_address_prefix")}"
      destination_address_prefix = "${lookup(var.SSH_rule, "destination_address_prefix")}"
   }

   security_rule {
      name = "${lookup(var.HTTP_rule, "name")}"
      priority = "${lookup(var.HTTP_rule, "priority")}"
      direction = "${lookup(var.HTTP_rule, "direction")}"
      access = "${lookup(var.HTTP_rule, "access")}"
      protocol = "${lookup(var.HTTP_rule, "protocol")}"
      source_port_range = "${lookup(var.HTTP_rule, "source_port_range")}"
      destination_port_ranges = ["80","8080"]
      source_address_prefix = "${lookup(var.HTTP_rule, "source_address_prefix")}"
      destination_address_prefix = "${lookup(var.HTTP_rule, "destination_address_prefix")}"
   }
}

resource "azurerm_network_interface" "NetworkInterface-01" {
   name = "${lookup(var.NetworkInterface, "name")}-${lookup(var.Bastion, "name")}"
   location = "${var.location}"
   resource_group_name = "${azurerm_resource_group.RG.name}"
   ip_configuration {
      name = "${lookup(var.NetworkInterface, "ip_configuration")}"
      subnet_id = "${azurerm_subnet.Subnet.id}"
      private_ip_address_allocation = "${lookup(var.NetworkInterface, "address_allocation")}"
      private_ip_address = "${lookup(var.Bastion, "private_ip")}"
      public_ip_address_id = "${element(azurerm_public_ip.PublicIP.*.id, count.index)}"
   }
   network_security_group_id = "${azurerm_network_security_group.NetworkSG.id}"

   tags {
      environment = "${var.tag}"
   }
}

resource "azurerm_virtual_machine" "Bastion" {
   name = "${lookup(var.Bastion, "name")}"
   location = "${var.location}"
   resource_group_name = "${azurerm_resource_group.RG.name}"
   network_interface_ids = ["${azurerm_network_interface.NetworkInterface-01.id}"]
   vm_size = "${lookup(var.AVM, "vm_size")}"

   storage_os_disk {
      name = "${lookup(var.storage_disk, "name")}-${lookup(var.Bastion, "name")}"
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
      computer_name = "${lookup(var.Bastion, "name")}"
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
      storage_uri = "${azurerm_storage_account.StorageAccount.primary_blob_endpoint}"
   }

   tags {
      environment = "${var.tag}"
   }
}