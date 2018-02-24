#!/usr/bin/env bash

if [ -f '../api/common_function.sh' ]
 then
  source ../api/common_function.sh
  else
  source './api/common_function.sh'
fi


#${1} =name  ${2}=description  ${3}=compute
function openstack_create_service(){
    openstack service create --name "${1}"' ' --description "${2}"' ' "${3}";
}

#【2】配置网络选项 linux bridge
function configure_networking_options(){
	read -p '
		1===configure_networking_options_public_main   ( Linux bridge 和 flat只适合小型场景)
		2===configure_networking_options_private
		3===vlan适合中型场景
		4===gre+vxlan适合大型场景
    ' number
		case ${number} in
            1)
            source ./network/network_public.sh ;;
             2)
            source ./network/network_private.sh ;;
            *)
            echo '没选择';;
	   esac
}

#【3】#配置元数据主机以及共享密码：
function configure_metadata_agent_ini(){
    append_section {$section_default,"nova_metadata_ip="${CONTROLLER_HOST_NAME},$ini_metadata_agent}
    append_section {$section_default,"metadata_proxy_shared_secret="${METADATA_SECRET},$ini_metadata_agent}
}
#【4】[neutron]`配置访问参数，启用元数据代理并设置密码：
function configure_nova_conf_neutron(){
    conf_section_access {'neutron',${NEUTRON_PASS},$section_neutron,$nova_conf}
    append_section {$section_neutron,"url=${url_9696}",$nova_conf}
    append_section {$section_neutron,"service_metadata_proxy=True",$nova_conf}
    append_section {$section_neutron,"metadata_proxy_shared_secret=${METADATA_SECRET}",$nova_conf}
}
#【5】[neutron]`配置访问参数，启用元数据代理并设置密码：
function finalize_installation(){
    ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini
    su -s /bin/sh -c "neutron-db-manage --config-file ${neutron_conf}  --config-file ${ini_ml2_conf} upgrade head" neutron
    systemctl restart openstack-nova-api.service
    systemctl enable neutron-server.service neutron-linuxbridge-agent.service neutron-dhcp-agent.service neutron-metadata-agent.service
    systemctl start neutron-server.service  neutron-linuxbridge-agent.service neutron-dhcp-agent.service neutron-metadata-agent.service
    install_start_service neutron-l3-agent
}

#【1】先决条件
function controller_prerequisites(){
    #select user，host from mysql.user;
    mysql_auth_main {'neutron','neutron',$NEUTRON_DBPASS}
    source ${admin_openrc_sh}
    openstack_create_user_to_group {'neutron','service','admin'}
    openstack_create_service {neutron,"OpenStackNetworking",network}
    openstack_loop_create_service_api_endpoint {'network',9696}
}

function network_controller_main(){
    controller_prerequisites
    configure_networking_options
    configure_metadata_agent_ini
    configure_nova_conf_neutron
    finalize_installation
}