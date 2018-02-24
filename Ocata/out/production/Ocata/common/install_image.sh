#!/bin/sh
#3镜像服务
function install_image() {
	prompt 'image'
	registry_conf='/etc/glance/glance-registry.conf'
	api_conf='/etc/glance/glance-api.conf'
	#⑴建glance库表：
    install_mysql_auth 'glance' ${GLANCE_DBPASS}
	# 安装和配置
	#先决条件 要创建服务证书，完成这些步骤： 创建 glance 用户：
	source /usr/share/keystone/admin-openrc.sh
    install_create_user_to_group glance service admin #添加 admin 角色到 glance 用户和 service 项目上。
	install_openstack_create_service glance 'OpenStack Image' image #创建``glance``服务实体：
	source ${2}admin-openrc.sh
	install_create_endpoint 'image' 9292
	#安全并配置组件 #glance-api.conf && glance-registry.conf
	yum -y install openstack-glance
    install_openstack_glance_conf ${api_conf} && install_openstack_glance_conf ${registry_conf}
	sed -i "/^\[glance_store\]$/a\stores = file,http \ndefault_store = file \nfilesystem_store_datadir = /var/lib/glance/images/" ${api_conf}
	cat ${api_conf} | grep -3 '^\[keystone_authtoken\]$'
	cat ${api_conf} | grep -3 '^\[glance_store\]$'
	#4写入镜像服务数据库：
	su -s /bin/sh -c "glance-manage db_sync" glance
	for svc in 'openstack-glance-api openstack-glance-registry '; do install_start_service ${svc} ; done
}