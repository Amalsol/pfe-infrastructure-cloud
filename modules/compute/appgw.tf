# IP Publique pour l'Application Gateway
resource "azurerm_public_ip" "appgw_pip" {
  name                = "pip-appgw"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Application Gateway avec WAF v2
resource "azurerm_application_gateway" "appgw" {
  name                = "appgw-pfe"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 1
  }

  # Subnet dédié
  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = var.appgw_subnet_id
  }

  # IP publique frontend
  frontend_ip_configuration {
    name                 = "appgw-frontend-ip"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  # Port HTTP 80
  frontend_port {
    name = "port-http"
    port = 80
  }

  # Port HTTPS 443
  frontend_port {
    name = "port-https"
    port = 443
  }

  # Backend — web-vm
  backend_address_pool {
    name         = "backend-pool"
    ip_addresses = ["10.0.2.4"]
  }

  # Health probe
  probe {
    name                = "http-probe"
    protocol            = "Http"
    path                = "/"
    host                = "10.0.2.4"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
  }

  # Backend HTTP settings
  backend_http_settings {
    name                  = "backend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
    probe_name            = "http-probe"
  }

  # Listener HTTP
  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "appgw-frontend-ip"
    frontend_port_name             = "port-http"
    protocol                       = "Http"
  }

  # Routing rule HTTP
  request_routing_rule {
    name                       = "http-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "backend-http-settings"
    priority                   = 100
  }

  # WAF Configuration
  waf_configuration {
    enabled          = true
    firewall_mode    = "Detection"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
  }
}