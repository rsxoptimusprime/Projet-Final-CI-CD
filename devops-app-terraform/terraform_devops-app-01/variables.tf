variable subscription_id {}
variable client_id {}
variable client_secret {}
variable tenant_id {}

variable RG_name {}
variable location {}
variable location2 {}
variable tag {}

variable Network_name {}
variable address_space {}

variable Subnet_name {}
variable Subnet_address_prefix {}

variable PublicIP_name {}
variable address_allocation {}

variable private_ip_adresses {
  type = "list"
}

variable NSG_name {}

variable SSH_rule {
  type = "map"
}

variable HTTP_rule {
  type ="map"
}

variable NetworkInterface {
  type = "map"
}

variable StorageAccount {
  type = "map"
}

variable AVM {
  type = "map"
}

variable storage_disk {
  type = "map"
}

variable image_reference{
  type = "map"
}

variable Bastion {
  type ="map"
}