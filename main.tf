provider "docker"{
   host = "tcp://127.0.0.1:2375/"
}
resource "docker_network" "private_network" {
  name = "my_network"
}
resource "docker_container" "zabbix-server" {
  image = "${docker_image.zabbix-server.latest}"
  must_run = true
  networks = [ "${docker_network.private_network.name}" ]
  env = ["MYSQL_ROOT_PASSWORD=zabbix", "MYSQL_PASSWORD=zabbix", "MYSQL_DATABASE=zabbix", "MYSQL_USER=zabbix"]
  name  = "zabbix-server"
  hostname = "zabbix-server"
     ports {
        internal = 10051
        external = 10051
        }
 
  volumes {
    container_path  = "/etc/localtime/"
    host_path = "/c/etc/localtime/"
    read_only = false
} 

}
resource "docker_container" "zabbix-apache" {
  image = "${docker_image.zabbix-apache.latest}"
  must_run = true
  networks = [ "${docker_network.private_network.name}" ]
  env = ["ZBX_ENABLE_SNMP_TRAPS=true", "MYSQL_ROOT_PASSWORD=zabbix", "MYSQL_PASSWORD=zabbix", "MYSQL_DATABASE=zabbix"]
  name = "zabbix-apache"
  hostname = "zabbix-apache"
  ports {
        internal = 80
        external = 80
        }
  ports {
        internal = 443
        external = 443
        }
   volumes {
    container_path  = "/etc/localtime/"
    host_path = "/c/etc/localtime/"
    read_only = false
}
}
resource "docker_container" "mysql-server" {
  image = "mysql:8.0"
  must_run = true
  networks = [ "${docker_network.private_network.name}" ]
  name = "mysql-server"
  hostname = "mysql-server"
  env = ["MYSQL_ROOT_PASSWORD=zabbix", "MYSQL_PASSWORD=zabbix", "MYSQL_DATABASE=zabbix"]
  command = ["mysqld", "--character-set-server=utf8", "--collation-server=utf8_bin", "--default-authentication-plugin=mysql_native_password"]
}
resource "docker_image" "zabbix-server" {
  name = "zabbix/zabbix-server-mysql:alpine-4.4-latest"
}
resource "docker_image" "mysql" {
  name = "mysql:8.0"
}
resource "docker_image" "zabbix-apache" {
  name = "zabbix/zabbix-web-apache-mysql:alpine-4.4-latest"
}
