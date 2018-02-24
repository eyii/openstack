#!/usr/bin/env bash
#Configure the administrative account
if [ -f '../api/common_function.sh' ]; then
  source '../api/common_function.sh'
  else
  source './api/common_function.sh'
fi

function config_administrator_account(){
export OS_USERNAME=admin
export OS_PASSWORD=${ADMIN_PASS}
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=${url_35357_v3}
export OS_IDENTITY_API_VERSION=3
}

function export_openstack_identity(){
  export OS_USERNAME=admin && export OS_PASSWORD=${ADMIN_PASS} && export OS_PROJECT_NAME=admin &&
  export OS_USER_DOMAIN_NAME=Default && export OS_PROJECT_DOMAIN_NAME=Default && export OS_AUTH_URL=${url_35357_v3} && export OS_IDENTITY_API_VERSION=3
}
function install_apache(){
    remove_file {$httpd_wsgi_keytone_conf,}
    yum_reinstall {'httpd mod_wsgi',}
	cp  {$httpdconf,$httpdconf'.bak'}
	sed  -i  "s/${section_apache}/ServerName ${CONTROLLER_HOST_NAME}/" ${httpdconf}
	ln -s ${wsgi_keystone_conf} /etc/httpd/conf.d/
    search {$section_apache,$httpdconf}
	install_start_service httpd #启动服务
    config_administrator_account
}
install_apache