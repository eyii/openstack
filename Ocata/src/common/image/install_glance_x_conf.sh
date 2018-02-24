#!/usr/bin/env bash
if [ -f '../api/common_function.sh' ]; then
  source '../api/common_function.sh'
  else
  source './api/common_function.sh'
fi
#【3】安全并配置组件 #glance-api.conf && glance-registry.conf
#删除[keystone_authtoken]其他项


function config_section_glance_store(){
    append_section {$section_glance_store,"stores=file,http",$1} ;
    append_section {$section_glance_store,"default_store=file",$1}
    append_section {$section_glance_store,"filesystem_store_datadir=/var/lib/glance/images",$1}
}

function openstack_glance_conf(){
    del_row {'^connection =',$1}
	openstack_append_section_database_connection {glance,$GLANCE_DBPASS,$1}
	#[keystone_authtoken]
	prompt '#[keystone_authtoken]'
	config_section_keytone_authtoken {'glance',${GLANCE_PASS},$1}
	#[paste_deploy]
	del_row {'^flavor=',$1}
	append_section {$section_paste_deploy,'flavor=keystone',$1};
}

function install_glance_x_conf(){
    yum_reinstall {'openstack-glance',}
    openstack_glance_conf ${api_conf}
    openstack_glance_conf ${registry_conf}
    config_section_glance_store {$api_conf,}
    search {$section_keystone_authtoken,$api_conf};
    search {$section_keystone_authtoken,$registry_conf};
    search {$section_glance_store,$api_conf};

}