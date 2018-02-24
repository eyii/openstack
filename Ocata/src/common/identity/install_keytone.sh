#!/usr/bin/env bash
if [ -f '../api/common_function.sh' ]; then
  source '../api/common_function.sh'
  else
  source './api/common_function.sh'
fi


function install_keystone(){
    yum_reinstall {'openstack-keystone',}
    #[DEFAULT]
	prompt 'admin_token';
#	ADMIN_TOKEN=$(openssl rand -hex 10);
    replace {'#trace\s=\sfalse','trace=true',$keystone_conf}
	replace {'#debug\s=\sfalse','debug=true',$keystone_conf}
	append_section {$section_default,"admin_token=${ADMIN_TOKEN}",$keystone_conf} ;
	prompt 'openstack_append_section_database_connection';
    #[database]
    openstack_append_section_database_connection {keystone,$KEYSTONE_DBPASS,$keystone_conf};
    prompt '[token]';
	#[token]
	append_section {$section_token,"provider=fernet",$keystone_conf} ;
	prompt '导入keystone到数据库中'
    su -s /bin/sh -c "keystone-manage db_sync" keystone  #3Populate the Identity service database:
	#4Initialize Fernet key repositories:
    for svc in fernet_setup credential_setup ; do (keystone-manage ${svc} --keystone-user keystone --keystone-group keystone) ; done
	#5 Bootstrap the Identity service:
    keystone-manage bootstrap --bootstrap-password ${ADMIN_PASS} --bootstrap-admin-url ${url_35357_v3} --bootstrap-internal-url ${url_5000_v3} --bootstrap-public-url ${url_5000_v3} --bootstrap-region-id RegionOne
}