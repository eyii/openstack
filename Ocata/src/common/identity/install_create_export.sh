#!/usr/bin/env bash
if [ -f '../api/common_function.sh' ]; then
  source '../api/common_function.sh'
  else
  source './api/common_function.sh'
fi
function export_openstack_image_admin(){
	echo "export OS_PROJECT_DOMAIN_NAME=Default && export OS_USER_DOMAIN_NAME=Default && export OS_PROJECT_NAME=admin &&
	 export OS_USERNAME=admin && export OS_PASSWORD=${ADMIN_PASS} && export OS_AUTH_URL=${url_35357_v3} &&
	 export OS_IDENTITY_API_VERSION=3 && export OS_IMAGE_API_VERSION=2" >> ${1}
}
#image_demo
function export_openstack_image_demo(){
	echo "export OS_PROJECT_DOMAIN_NAME=Default && export OS_USER_DOMAIN_NAME=Default && export OS_PROJECT_NAME=demo &&
	export OS_USERNAME=demo && export OS_PASSWORD=${DEMO_PASS} && export OS_AUTH_URL=${url_5000_v3} && export OS_IDENTITY_API_VERSION=3 &&
	export OS_IMAGE_API_VERSION=2" >> ${1}
}
function install_export_sh(){
    cd ${dir_keystone}
	remove_file ${admin_openrc_sh}
	remove_file ${demo_openrc_sh}
	export_openstack_image_admin ${admin_openrc_sh}
	export_openstack_image_demo ${demo_openrc_sh}
	source ${admin_openrc_sh}
	openstack token issue;
#	source ${demo_openrc_sh}
#	openstack token issue;
}

