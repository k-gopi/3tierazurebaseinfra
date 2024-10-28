output "web_vm_id" {
  value = azurerm_linux_virtual_machine.web_vm.id
}
output "app_vm_id" {
  value = azurerm_linux_virtual_machine.app_vm.id
}
output "public_ip1" {
  value = azurerm_public_ip.web_vm_ip1.ip_address
}
output "public_ip2" {
#   value = azurerm_public_ip.lb_public_ip2.ip_address
  value = azurerm_public_ip.app_vm_ip1.ip_address
}
# output "public_ip3" {
# #   value = azurerm_public_ip.lb_public_ip2.ip_address
#   value = azurerm_public_ip.lb_ip1.ip_address
# }
output "sql_server_id" {
  value = azurerm_mssql_server.example.id
}

output "sql_database_id" {
  value = azurerm_mssql_database.example.id
}