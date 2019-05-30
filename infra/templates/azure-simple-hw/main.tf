module "provider" {
  source = "../../modules/providers/azure/provider"
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}"
  location = "${var.resource_group_location}"
}

module "service_plan" {
  source              = "../../modules/providers/azure/service-plan"
  resource_group_name = "${azurerm_resource_group.main.name}"
  service_plan_name   = "${azurerm_resource_group.main.name}-sp"
}

module "app_service" {
  source                           = "../../modules/providers/azure/app-service"
  app_service_name                 = "${var.app_service_name}"
  service_plan_name                = "${module.service_plan.service_plan_name}"
  service_plan_resource_group_name = "${azurerm_resource_group.main.name}"
  enable_storage                   = "${var.websites_enable_app_service_storage}"
  docker_registry_server_url       = "${var.docker_registry_server_url}"
}
