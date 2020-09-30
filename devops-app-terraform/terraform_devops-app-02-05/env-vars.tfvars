subscription_id = "fd219698-5485-44bf-9995-7fa1a02d985d"
client_id = "09d21648-4060-45a2-863a-97620a29557e"
client_secret = "7e7e3799-9375-4829-b5bc-352fc040b357"
tenant_id = "f807c3e9-4482-4b39-b72d-d1a1bf7306d8"

RG_name = "CloudPIC"
location = "northeurope"
location2= "westeurope"
tag = "CloudPIC"


Network_name = "Network"
address_space = "10.0.0.0/16"

Subnet_name = "Subnet"
Subnet_address_prefix = "10.0.2.0/24"

PublicIP_name = "PublicIP"
address_allocation = "dynamic"

NSG_name = "NetworkSecurityGroup"

NSG_rule = {
  name = "SSH"
  priority = 1001
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_range = "22"
  source_address_prefix = "*"
  destination_address_prefix = "*"
}


NSG_Rule_HTTP = {
  name = "HTTP"
  priority = 300
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_range = "8080"
  source_address_prefix = "*"
  destination_address_prefix = "*"
}

NetworkInterface = {
  name = "NetworkInterface"
  ip_configuration = "NetworkInterfaceConfiguration"
  address_allocation = "static"

}

StorageAccount = {
  account_replication_type = "LRS"
  account_tier = "Standard"
}

AVM = {
  name = "devops-app-0"
  vm_size = "Standard_DS1_v2"
  admin_username = "stage"
}


storage_disk = {
  name = "OSDisk"
  caching = "ReadWrite"
  create_option = "FromImage"
  managed_disk_type = "Premium_LRS"
}

image_reference = {
  publisher = "Canonical"
  offer = "UbuntuServer"
  sku = "16.04.0-LTS"
  version = "latest"
}


Bastion = {
  name = "apache"
  private_ip = "10.0.2.4"
}

private_ip_adresses = ["10.0.2.5","10.0.2.6","10.0.2.7"]
