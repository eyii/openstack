#!/usr/bin/env bash
if [ -f '../api/common_function.sh' ]; then
  source '../api/common_function.sh'
  else
  source './api/common_function.sh'
fi


:<<comment
#https://docs.openstack.org/ocata/install-guide-rdo/keystone.html
Identity service overview
Install and configure
    Prerequisites
    Install and configure components
    Configure the Apache HTTP server
    Finalize the installation
Create a domain, projects, users, and roles
Verify operation
Create OpenStack client environment scripts
    Creating the scripts
    Using the scripts
comment


function main_identity(){
		read -p '
		#【1】Prerequisites 建keystone库表
		#【2】Install and configure components
		#【3】Configure the Apache HTTP server
		#【4】Create a domain, projects, users, and roles
		#【5】Create export
		#【6】vertify
		' number
		case ${number} in
            1)
            mysql_auth_main {'keystone','keystone',$KEYSTONE_DBPASS} ;;
            2)
               source ./identity/install_keytone.sh
                if [ -f './install_keytone.sh' ]; then
                 source ./install_keytone.sh
                 fi
                 install_keystone;;
            3)
             source ./identity/install_apache.sh
             if [ -f './install_apache.sh' ]; then
             source ./install_apache.sh
             fi;;
            4)
           source ./identity/install_openstack_create_user.sh
             if [ -f './install_openstack_create_user.sh' ]; then
             source ./install_openstack_create_user.sh
             fi
            openstack_create_user;;
            5)
            source ./identity/install_create_export.sh
             if [ -f './install_create_export.sh' ]; then
                source ./install_create_export.sh
             fi
            install_export_sh;;
            6)
                source ./identity/install_verify.sh
                if [ -f './install_verify.sh' ]; then
                source ./install_verify.sh
                fi
	   esac
}


   #禁用令牌
	#sed -i 's/request_id admin_token_auth build_auth_context/request_id build_auth_context/g' $1 && cat $1 |grep -5 'admin_token_auth'
	#
	#openstack --os-auth-url http://controller:35357/v3  --os-project-domain-name default --os-user-domain-name default --os-project-name admin --os-username admin token issue
	#openstack --os-auth-url http://controller:5000/v3 --os-project-domain-name default --os-user-domain-name default  --os-project-name demo --os-username demo token issue