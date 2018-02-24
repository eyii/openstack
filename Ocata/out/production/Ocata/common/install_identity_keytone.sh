#!/bin/sh


#2身份认证服务
function install_identity_keytone(){
	prompt '2Identity'
	#⑴建keystone库表：
	install_mysql_auth 'keystone' ${KEYSTONE_DBPASS}
	#⑵安装keystone
	install_keystone '/etc/keystone/keystone.conf'
	#Apache
	cp  ${httpdconf} ${httpdconf}'.bak' && sed  -i  "s/^#ServerName.*/ServerName ${CONTROLLER_HOST_NAME}/" ${httpdconf} && ln -s /usr/share/keystone/wsgi-keystone.conf /etc/httpd/conf.d/ && cat ${httpdconf}|grep -5 '^ServerName.*'  #⑶Configure the Apache HTTP server
	install_start_service httpd #启动服务
    export OS_USERNAME=admin && export OS_PASSWORD=${ADMIN_PASS} && export OS_PROJECT_NAME=admin && export OS_USER_DOMAIN_NAME=Default && export OS_PROJECT_DOMAIN_NAME=Default && export OS_AUTH_URL=${url_35357} && export OS_IDENTITY_API_VERSION=3
	#⑷Create a domain, projects, users, and roles
	install_create_user
	#⑸Verify operation
	#禁用令牌
	#sed -i 's/request_id admin_token_auth build_auth_context/request_id build_auth_context/g' $1 && cat $1 |grep -5 'admin_token_auth'
	#unset OS_AUTH_URL OS_PASSWORD
	install_openstack_auth 35357 admin && install_openstack_auth 5000 demo
	#⑹创建脚本
	cd /usr/share/keystone/
	rm -f ${2}admin-openrc.sh
	rm -f ${2}demo-openrc.sh
	echo "export OS_PROJECT_DOMAIN_NAME=Default && export OS_USER_DOMAIN_NAME=Default && export OS_PROJECT_NAME=admin && export OS_USERNAME=admin && export OS_PASSWORD=${ADMIN_PASS} && export OS_AUTH_URL=${url_35357} && export OS_IDENTITY_API_VERSION=3 && export OS_IMAGE_API_VERSION=2" >> ${2}admin-openrc.sh
	echo "export OS_PROJECT_DOMAIN_NAME=Default && export OS_USER_DOMAIN_NAME=Default && export OS_PROJECT_NAME=demo && export OS_USERNAME=demo && export OS_PASSWORD=${DEMO_PASS} && export OS_AUTH_URL=${url_5000} && export OS_IDENTITY_API_VERSION=3 && export OS_IMAGE_API_VERSION=2" >> ${2}demo-openrc.sh
	source ${2}admin-openrc.sh
	openstack token issue
	source ${2}demo-openrc.sh
	openstack token issue
	#Using the scripts
}