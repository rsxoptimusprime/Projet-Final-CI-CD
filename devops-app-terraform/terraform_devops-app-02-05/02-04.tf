resource "azurerm_network_security_group" "NetworkSGdefault" {
   name = "${var.NSG_name}default"
   location = "${var.location}"
   resource_group_name = "${data.azurerm_resource_group.RG.name}"
   tags {
      environment = "${var.tag}"
   }
}

resource "azurerm_network_interface" "NetworkInterface" {
  name = "${lookup(var.NetworkInterface, "name")}${count.index+2}"
  location = "${var.location}"
  resource_group_name = "${data.azurerm_resource_group.RG.name}"
  ip_configuration {
    name = "${lookup(var.NetworkInterface, "ip_configuration")}"
    subnet_id = "${data.azurerm_subnet.Subnet.id}"
    private_ip_address_allocation = "${lookup(var.NetworkInterface, "address_allocation")}"
    private_ip_address= "${(var.private_ip_adresses [count.index])}"}

    network_security_group_id = "${azurerm_network_security_group.NetworkSGdefault.id}"

  tags {
    environment = "${var.tag}"
  }
  count = "${length(var.private_ip_adresses)}"
}


resource "azurerm_virtual_machine" "AVM" {
  name = "${lookup(var.AVM, "name")}${count.index+2}"
  location = "${var.location}"
  resource_group_name = "${data.azurerm_resource_group.RG.name}"
  network_interface_ids = ["${element(azurerm_network_interface.NetworkInterface.*.id, count.index)}"]
  vm_size = "${lookup(var.AVM, "vm_size")}"

  storage_os_disk {
    name = "${lookup(var.storage_disk, "name")}${count.index}"
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
    computer_name = "${lookup(var.AVM, "name")}${count.index+2}"
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
    storage_uri = "${data.azurerm_storage_account.storage_account.primary_blob_endpoint}"
  }

  tags {
    environment = "${var.tag}"
  }
  count = "${length(var.private_ip_adresses)}"
}
