resource "shoreline_notebook" "mysql_slave_io_thread_not_running_incident_on_kubernetes" {
  name       = "mysql_slave_io_thread_not_running_incident_on_kubernetes"
  data       = file("${path.module}/data/mysql_slave_io_thread_not_running_incident_on_kubernetes.json")
  depends_on = [shoreline_action.invoke_check_network_connectivity,shoreline_action.invoke_restart_mysql_slave_io_thread]
}

resource "shoreline_file" "check_network_connectivity" {
  name             = "check_network_connectivity"
  input_file       = "${path.module}/data/check_network_connectivity.sh"
  md5              = filemd5("${path.module}/data/check_network_connectivity.sh")
  description      = "Network connectivity issue between the master and slave databases."
  destination_path = "/agent/scripts/check_network_connectivity.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "restart_mysql_slave_io_thread" {
  name             = "restart_mysql_slave_io_thread"
  input_file       = "${path.module}/data/restart_mysql_slave_io_thread.sh"
  md5              = filemd5("${path.module}/data/restart_mysql_slave_io_thread.sh")
  description      = "Restart the MySQL Slave IO thread on the affected instance."
  destination_path = "/agent/scripts/restart_mysql_slave_io_thread.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_check_network_connectivity" {
  name        = "invoke_check_network_connectivity"
  description = "Network connectivity issue between the master and slave databases."
  command     = "`chmod +x /agent/scripts/check_network_connectivity.sh && /agent/scripts/check_network_connectivity.sh`"
  params      = ["MASTER_POD_NAME","SLAVE_POD_NAME","NAMESPACE"]
  file_deps   = ["check_network_connectivity"]
  enabled     = true
  depends_on  = [shoreline_file.check_network_connectivity]
}

resource "shoreline_action" "invoke_restart_mysql_slave_io_thread" {
  name        = "invoke_restart_mysql_slave_io_thread"
  description = "Restart the MySQL Slave IO thread on the affected instance."
  command     = "`chmod +x /agent/scripts/restart_mysql_slave_io_thread.sh && /agent/scripts/restart_mysql_slave_io_thread.sh`"
  params      = ["MYSQL_CONTAINER_NAME","MYSQL_POD_NAME","MYSQL_PASSWORD"]
  file_deps   = ["restart_mysql_slave_io_thread"]
  enabled     = true
  depends_on  = [shoreline_file.restart_mysql_slave_io_thread]
}

