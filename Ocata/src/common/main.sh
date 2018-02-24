#!/usr/bin/env bash

#tr_unix
source ./api/common_function.sh
is_root
#1
source ./env/install_env.sh
#2
source ./identity/identity_main.sh
#3
source image/install_main.sh
#4
source ./compute_nova/compute_main.sh
#5
source network/networking_main.sh
#6
source dashboard/install_dashboard.sh

prompt 'OpenStack Ocata 安装（一）环境准备 https://docs.openstack.org/ocata/install-guide-rdo/environment-packages.html'
#http://mirror.centos.org/centos/7/cloud/x86_64/openstack-ocata/
#https://repos.fedorapeople.org/repos/openstack/openstack-ocata/
function main(){
		read -p '
		1===install_environment
		2===install_identity_keytone
		3===install_Image
		4===install_compute
		5===install_networking
		6===install_dashboard
		' number
		case ${number} in
            1)
            main_environment {$chrony_conf,} | tee -a /var/log/openstack_install_environment.log;;
            2)
            main_identity {$ini_keystone_paste,$dir_keystone} | tee -a /var/log/openstack_install_identity.log;;
            3)
            main_image {'1',$dir_keystone}  | tee -a /var/log/openstack_install_Image.log;;
            4)
            main_compute | tee -a /var/log/openstack_install_compute.log;;
            5)
            main_networking | tee -a /var/log/openstack_install_compute.log;;
            6)
		    main_dashboard ;;
	   esac
}
main
