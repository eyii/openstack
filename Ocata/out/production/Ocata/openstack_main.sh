#!/bin/sh
#source ./common/*.sh

source ./common/function.sh
#1
source ./common/install_environment.sh
#2
source ./common/install_identity_keytone.sh
#3
source ./common/install_image.sh
#4
source ./common/install_compute.sh
#5
source ./common/install_networking.sh
#6
source ./common/install_dashboard.sh

prompt 'OpenStack Ocata 安装（一）环境准备 https://docs.openstack.org/ocata/install-guide-rdo/environment-packages.html'
#http://mirror.centos.org/centos/7/cloud/x86_64/openstack-ocata/
#https://repos.fedorapeople.org/repos/openstack/openstack-ocata/
function main(){
		read -p '
		1===install_environment
		2===install_identity
		3===install_Image
		4===install_compute
		' number
		case ${number} in
			1)
			install_environment '/etc/chrony.conf' | tee -a /var/log/openstack_install_environment.log;;
			2)
			install_identity_keytone '/etc/keystone/keystone-paste.ini' '/usr/share/keystone/' | tee -a /var/log/openstack_install_identity.log;;
			3)
			install_image '1' '/usr/share/keystone/'  | tee -a /var/log/openstack_install_Image.log;;
			4)
			 install_compute | tee -a /var/log/openstack_install_compute.log;;
			 5)
			 install_networking | tee -a /var/log/openstack_install_compute.log;;
			  6)
			 install_dashboard | tee -a /var/log/openstack_install_compute.log;;
	   esac
}
main
