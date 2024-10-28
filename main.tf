terraform {}

resource "azurerm_resource_group" "main" {
  name     = var.rg_name
  location = var.location
}

resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "web" {
  name                 = var.subnet_web_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  #   address_prefix      = "10.0.1.0/24"
  address_prefixes = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "app" {
  name                 = var.subnet_app_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  #   address_prefix       = "10.0.2.0/24"
  address_prefixes = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "db" {
  name                 = var.subnet_db_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  #   address_prefix       = "10.0.3.0/24"
  address_prefixes = ["10.0.3.0/24"]
}

resource "azurerm_subnet" "lb" {
  name                 = var.subnet_lb_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  #   address_prefix       = "10.0.4.0/24"
  address_prefixes = ["10.0.4.0/24"]
}
resource "azurerm_network_security_group" "web_nsg" {
  name                = "webNSG"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_network_security_group" "app_nsg" {
  name                = "appNSG"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_network_security_group" "db_nsg" {
  name                = "dbNSG"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}
resource "azurerm_subnet_network_security_group_association" "web" {
  subnet_id                 = azurerm_subnet.web.id
  network_security_group_id = azurerm_network_security_group.web_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.app_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "db" {
  subnet_id                 = azurerm_subnet.db.id
  network_security_group_id = azurerm_network_security_group.db_nsg.id
}
resource "azurerm_availability_set" "example" {
  name                = "myAvailabilitySet"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  managed             = true
}

resource "azurerm_network_interface" "web_nic" {
  name                = "webNIC"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "webIPConfig"
    subnet_id                    = azurerm_subnet.web.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.web_vm_ip1.id
  }
}
resource "azurerm_linux_virtual_machine" "web_vm" {
  name                = "webVM"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  disable_password_authentication = false
  availability_set_id = azurerm_availability_set.example.id

  network_interface_ids = [azurerm_network_interface.web_nic.id]
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    name                 = "my-os-disk"
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}
resource "azurerm_network_interface" "app_nic" {
  name                = "appNIC"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "appIPConfig"
    subnet_id                    = azurerm_subnet.app.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.app_vm_ip1.id 
  }
}
resource "azurerm_linux_virtual_machine" "app_vm" {
  name                = "appVM"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  disable_password_authentication = false
  availability_set_id = azurerm_availability_set.example.id

  network_interface_ids = [azurerm_network_interface.app_nic.id]

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    name                 = "my-terraform-os-disk2"
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}
resource "azurerm_public_ip" "web_vm_ip1" {
  name                = "lbPublicIP1"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
  allocation_method   = "Static"
}
resource "azurerm_public_ip" "app_vm_ip1" {
  name                = "lbPublicIP2"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
  allocation_method   = "Static"
}
# resource "azurerm_public_ip" "lb_ip1" {
#   name                = "lbPublicIP1"
#   location            = azurerm_resource_group.main.location
#   resource_group_name = azurerm_resource_group.main.name
#   sku                 = "Standard"
#   allocation_method   = "Static"
# }
# resource "azurerm_lb" "example" {
#   name                = "example-lb"
#   location            = azurerm_resource_group.main.location
#   resource_group_name = azurerm_resource_group.main.name
#   sku                 = "Standard"
#   frontend_ip_configuration {
#     name                 = "PublicIPAddress"
#     public_ip_address_id = azurerm_public_ip.lb_ip.id
#   }
# }
resource "azurerm_public_ip" "example" {
  name                = "PublicIPForLB"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "example" {
  name                = "TestLoadBalancer"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.example.id
  }
}
resource "azurerm_lb_backend_address_pool" "example" {
  loadbalancer_id = azurerm_lb.example.id
  name            = "BackEndAddressPool"
}
resource "azurerm_network_interface_backend_address_pool_association" "example" {
  network_interface_id    = azurerm_network_interface.web_nic.id
  ip_configuration_name   = "webIPConfig"
  backend_address_pool_id = azurerm_lb_backend_address_pool.example.id
}
resource "azurerm_network_interface_backend_address_pool_association" "example2" {
  network_interface_id    = azurerm_network_interface.app_nic.id
  ip_configuration_name   = "appIPConfig"
  backend_address_pool_id = azurerm_lb_backend_address_pool.example.id
}
resource "azurerm_lb_probe" "example1" {
  loadbalancer_id = azurerm_lb.example.id
  name            = "Tcp-running-probe1"
  port            = 80
}
resource "azurerm_lb_probe" "example2" {
  loadbalancer_id = azurerm_lb.example.id
  name            = "Tcp-running-probe2"
  port            = 443
}
resource "azurerm_lb_rule" "example" {
  loadbalancer_id                = azurerm_lb.example.id
  name                           = "LBRule1"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
}
resource "azurerm_lb_rule" "example2" {
  loadbalancer_id                = azurerm_lb.example.id
  name                           = "LBRule2"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "PublicIPAddress"
}
resource "azurerm_mssql_server" "example" {
  name                         = "example-sqlserver837"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password
  azuread_administrator {
    login_username = "klakshmi1929_gmail.com#EXT#@klakshmi1929gmail.onmicrosoft.com"
    object_id      = "e1f0d181-4ff5-41ea-8770-de16cd50d43e"
  }
}
resource "azurerm_mssql_database" "example" {
  name         = "example-db"
  server_id    = azurerm_mssql_server.example.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  max_size_gb  = 2
  sku_name     = "S0"
  enclave_type = "VBS"

  tags = {
    foo = "bar"
  }
  lifecycle {
    prevent_destroy = false
    
  }
  
}
resource "azurerm_key_vault" "example" {
  name                = "examplekeyvault1293" # Must be globally unique
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = "standard" # Options: standard or premium

  tenant_id = "0348027f-051b-4e30-b2b8-02b2576a6277" # Replace with your Azure tenant ID
}
# data "azurerm_ad_service_principal" "terraform-sp" {
#   application_id = "4d0a4134-3a5d-4ee1-9a1c-1aa02b584dbf"  # Replace with the actual Application ID
# }
# Create an Access Policy for a User or Service Principal
resource "azurerm_key_vault_access_policy" "example" {
  key_vault_id = azurerm_key_vault.example.id
  tenant_id    = "0348027f-051b-4e30-b2b8-02b2576a6277" # Replace with your Azure tenant ID
  object_id    = "f1222138-afa3-45db-bef1-fb7cd53cbb2e" # Replace with the Object ID of the user/service principal

  # Specify the permissions you want to grant
  key_permissions    = ["Get", "List"]
  secret_permissions = ["Get", "Set"]
}
data "azuread_service_principal" "terraform-sp" {
  display_name = "terraform-sp"
}

# resource "azurerm_key_vault_access_policy" "example-principal" {
#   key_vault_id = azurerm_key_vault.example.id
#   tenant_id    = "0348027f-051b-4e30-b2b8-02b2576a6277"
#   object_id    = "f1222138-afa3-45db-bef1-fb7cd53cbb2e"

#   key_permissions = [
#     "Get", "List", "Encrypt", "Decrypt"
#   ]
# }
resource "azurerm_storage_account" "example" {
  name                = "storageaccount9726"
  resource_group_name = azurerm_resource_group.main.name

  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "BlobStorage"
}

resource "azurerm_storage_management_policy" "example" {
  storage_account_id = azurerm_storage_account.example.id

  rule {
    name    = "rule1"
    enabled = true
    filters {
      prefix_match = ["container1/prefix1"]
      blob_types   = ["blockBlob"]
    #   match_blob_index_tag {
    #     name      = "tag1"
    #     operation = "=="
    #     value     = "val1"
    #   }
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 10
        tier_to_archive_after_days_since_modification_greater_than = 50
        delete_after_days_since_modification_greater_than          = 100
      }
      snapshot {
        delete_after_days_since_creation_greater_than = 30
      }
    }
  }
  rule {
    name    = "rule2"
    enabled = false
    filters {
      prefix_match = ["container2/prefix1", "container2/prefix2"]
      blob_types   = ["blockBlob"]
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 11
        tier_to_archive_after_days_since_modification_greater_than = 51
        delete_after_days_since_modification_greater_than          = 101
      }
      snapshot {
        change_tier_to_archive_after_days_since_creation = 90
        change_tier_to_cool_after_days_since_creation    = 23
        delete_after_days_since_creation_greater_than    = 31
      }
      version {
        change_tier_to_archive_after_days_since_creation = 9
        change_tier_to_cool_after_days_since_creation    = 90
        delete_after_days_since_creation                 = 3
      }
    }
  }
}