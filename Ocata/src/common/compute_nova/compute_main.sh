#!/usr/bin/env bash
if [ -f '../api/common_function.sh' ]; then
  source '../api/common_function.sh'
  else
  source './api/common_function.sh'
fi




:<<comment
https://docs.openstack.org/ocata/install-guide-rdo/nova-controller-install.html
Compute service overview
Install and configure controller node
    Prerequisites
    Install and configure components
    Finalize installation
Install and configure a compute node
    Install and configure components
    Finalize installation
    Add the compute node to the cell database
Verify operation
comment
#source ./../common_function.sh

function vertify(){
    source ${admin_openrc_sh}
    # List service components to verify successful launch and registration of each process:
    openstack compute service list
    openstack catalog list
    openstack image list
    nova-status upgrade check
    nova-manage cell_v2 list_cells

}



function main_compute(){
		read -p '
		4计算服务nova ;
		#【1】compute_prerequisites_main;;
		#【2】compute_configure_controller_node_main;;
		#【3】Install and configure a compute node;;
		#【4】vertify
		' number
		case ${number} in
            1)
             source ./compute_nova/compute_prerequisites.sh
             if [ -f './compute_prerequisites.sh' ]; then
             source ./compute_prerequisites.sh
             fi
             compute_prerequisites_main;;
            2)
            source ./compute_nova/compute_install_config_components.sh
            if [ -f './compute_install_config_components.sh' ]; then
                source ./compute_install_config_components.sh
            fi
            compute_configure_controller_node_main;;
            3)
            #【6】Install and configure a compute node;;
            echo '1';;
            4)
              vertify;;
        esac
}
