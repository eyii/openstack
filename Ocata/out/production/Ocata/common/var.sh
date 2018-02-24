#!/bin/sh
RABBIT_PASS='1'
KEYSTONE_DBPASS='1'
mysql_username='root'
ADMIN_PASS='1'
GLANCE_DBPASS='1'
GLANCE_PASS='1'
DEMO_PASS='1'
NOVA_DBPASS='1'
mysql_pwd='1'
httpdconf='/etc/httpd/conf/httpd.conf'
CONTROLLER_HOST_NAME='controller'
MemcachedServers=${CONTROLLER_HOST_NAME}
mysql_port='3306'
host=$(hostname)
ipaddress=$(ifconfig | sed -n 2p | awk '{print $2}')
url_35357="http://${CONTROLLER_HOST_NAME}:35357/v3/"
url_5000="http://${CONTROLLER_HOST_NAME}:5000/v3/"