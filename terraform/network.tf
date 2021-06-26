# Creación de red
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network

resource "azurerm_virtual_network" "miRed" {
    name                = "redP2UNIR"
    address_space       = ["192.168.0.0/16"]
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    tags = {
        environment = "CP2"
    }
}

# Creación de subnet
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet

resource "azurerm_subnet" "miSubred" {
    name                   = "subredP2UNIR"
    resource_group_name    = azurerm_resource_group.rg.name
    virtual_network_name   = azurerm_virtual_network.miRed.name
    address_prefixes       = ["192.168.1.0/24"]

}

# Interfaces de Red
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface

resource "azurerm_network_interface" "interfazNFS" {
  name                = "myinterfazNFS"  
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
    name                           = "configuracionNFS"
    subnet_id                      = azurerm_subnet.miSubred.id 
    private_ip_address_allocation  = "Static"
    private_ip_address             = "192.168.1.115"
    public_ip_address_id           = azurerm_public_ip.ipPublicaNFS.id
  }

    tags = {
        environment = "CP2"
    }

}

resource "azurerm_network_interface" "interfazMASTER" {
  name                = "myinterfazMASTER"  
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
    name                           = "configuracionMASTER"
    subnet_id                      = azurerm_subnet.miSubred.id 
    private_ip_address_allocation  = "Static"
    private_ip_address             = "192.168.1.110"
    public_ip_address_id           = azurerm_public_ip.ipPublicaMASTER.id
  }

    tags = {
        environment = "CP2"
    }

}

resource "azurerm_network_interface" "interfazWORKER01" {
  name                = "myinterfazWORKER01"  
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
    name                           = "configuracionWORKER01"
    subnet_id                      = azurerm_subnet.miSubred.id 
    private_ip_address_allocation  = "Static"
    private_ip_address             = "192.168.1.111"
    public_ip_address_id           = azurerm_public_ip.ipPublicaWORKER01.id
  }

    tags = {
        environment = "CP2"
    }

}

resource "azurerm_network_interface" "interfazWORKER02" {
  name                = "myinterfazWORKER02"  
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
    name                           = "configuracionWORKER02"
    subnet_id                      = azurerm_subnet.miSubred.id 
    private_ip_address_allocation  = "Static"
    private_ip_address             = "192.168.1.112"
    public_ip_address_id           = azurerm_public_ip.ipPublicaWORKER02.id
  }

    tags = {
        environment = "CP2"
    }

}

# IPs públicas
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip

resource "azurerm_public_ip" "ipPublicaNFS" {
  name                = "vmipNFS"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"

    tags = {
        environment = "CP2"
    }

}

resource "azurerm_public_ip" "ipPublicaMASTER" {
  name                = "vmipMASTER"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"

    tags = {
        environment = "CP2"
    }

}

resource "azurerm_public_ip" "ipPublicaWORKER01" {
  name                = "vmipWORKER01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"

    tags = {
        environment = "CP2"
    }

}

resource "azurerm_public_ip" "ipPublicaWORKER02" {
  name                = "vmipWORKER02"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"

    tags = {
        environment = "CP2"
    }

}