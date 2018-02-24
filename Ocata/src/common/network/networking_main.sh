#!/usr/bin/env bash
if [ -f '../api/common_function.sh' ]; then
  source '../api/common_function.sh'
  else
  source './api/common_function.sh'
fi


function verify_operation(){
source $admin_openrc_sh
#List loaded extensions to verify successful launch of the neutron-server process:
openstack extension list --network
}

function next_steps(){
echo 1;
}
function main_networking(){
        prompt '5 网络服务neutron';
		read -p '
		1===network_controller.sh
		2===install_and_configure_compute_node
		3===verify_operation
		4===next_steps
		' number1
		case ${number1} in
            1)
            source ./network/network_controller.sh
            network_controller_main;;
            2)
            source ./network/network_compute.sh
             network_compute_node_main;;
            3)
            verify_operation;;
            4)
           next_steps;;
	   esac
}

