#!/bin/sh
prompt '4计算服务';
function install_compute(){
	#创建数据库并授权：
	for i in 'nova_api nova nova_cell0'; do install_mysql_auth ${i} ${NOVA_DBPASS} ; done
	source '/usr/share/keystone/admin-openrc.sh'
    #nova服务
    for i in 'nova placement'; do install_create_user_to_group ${i} service admin; done
     install_openstack_create_service nova 'OpenStack Compute' compute && install_create_endpoint 'compute' '8774/v2.1'
    #placement服务
	install_openstack_create_service placement "Placement API" placement && install_create_endpoint 'placement' 8778
    list='api conductor console novncproxy scheduler placement-api' && for svc in ${list};do yum -y install openstack-nova-${svc}; done
    append_section '\[DEFAULT\]' 'enabled_apis = osapi_compute,metadata'
}