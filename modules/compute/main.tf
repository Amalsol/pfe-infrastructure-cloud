# IP Publique Bastion
resource "azurerm_public_ip" "bastion_pip" {
  name                = "pip-bastion"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# NIC Bastion
resource "azurerm_network_interface" "bastion_nic" {
  name                = "nic-bastion"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "bastion-ip-config"
    subnet_id                     = var.public_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion_pip.id
  }
}

# Bastion VM
resource "azurerm_linux_virtual_machine" "bastion" {
  name                = "bastion-vm"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [azurerm_network_interface.bastion_nic.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.bastion_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}

# NIC Web VM
resource "azurerm_network_interface" "web_nic" {
  name                = "nic-web"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "web-ip-config"
    subnet_id                     = var.private_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# Web VM
resource "azurerm_linux_virtual_machine" "web" {
  name                = "web-vm"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [azurerm_network_interface.web_nic.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.web_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    systemctl enable nginx
    systemctl start nginx
    echo "<h1>PFE - Infrastructure Cloud Securisee</h1><p>Deploye avec Terraform</p>" > /var/www/html/index.html
  EOF
  )
}
# NIC Database VM
resource "azurerm_network_interface" "db_nic" {
  name                = "nic-db"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "db-ip-config"
    subnet_id                     = var.db_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# Database VM
resource "azurerm_linux_virtual_machine" "db" {
  name                = "db-vm"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [azurerm_network_interface.db_nic.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.db_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  # Cloud-init : installer PostgreSQL automatiquement
  custom_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y postgresql postgresql-contrib
    systemctl enable postgresql
    systemctl start postgresql
    # Créer la base de données PFE
    sudo -u postgres psql -c "CREATE DATABASE pfe_db;"
    sudo -u postgres psql -c "CREATE USER pfe_user WITH PASSWORD 'pfe2026';"
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE pfe_db TO pfe_user;"
    # Permettre les connexions depuis le subnet web
    echo "host pfe_db pfe_user 10.0.2.0/24 md5" >> /etc/postgresql/16/main/pg_hba.conf
    sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '10.0.3.4'/" /etc/postgresql/16/main/postgresql.conf
    systemctl restart postgresql
  EOF
  )
}




