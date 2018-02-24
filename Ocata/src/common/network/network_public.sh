#!/usr/bin/env bash

if [ -f '../api/common_function.sh' ]
 then
  source ../api/common_function.sh
  else
  source './api/common_function.sh'
fi


function config_section_default_neutron(){
    append_section {$section_default,'core_plugin=ml2 \nservice_plugins=',$neutron_conf};
    append_section {$section_default,"transport_url=rabbit://openstack:${RABBIT_PASS}@${CONTROLLER_HOST_NAME}",$neutron_conf};
    append_section {$section_default,'auth_strategy=keystone',$neutron_conf};
    append_section {$section_default,"notify_nova_on_port_status_changes=true \nnotify_nova_on_port_data_changes=true",$neutron_conf};
}
#【2】配置服务组件neutron #/etc/neutron/neutron.conf 服务器组件的配置包括数据库、认证机制、消息队列、拓扑变化通知和插件
 function conf_neutron_conf(){
    prompt '/etc/neutron/neutron.conf'
    openstack_append_section_connection {$section_database,neutron,$NEUTRON_DBPASS,$neutron_conf}
    config_section_default_neutron
    config_section_keytone_authtoken {'neutron',${NEUTRON_PASS},$neutron_conf}
    append_section {$section_oslo_concurrency,'lock_path=/var/lib/neutron/tmp',$neutron_conf};
    conf_section_access {'nova',${NOVA_PASS},$section_nova,$neutron_conf}
}

#【3】配置 Modular Layer 2 (ML2) 插件 #/etc/neutron/plugins/ml2/ml2_conf.ini
function conf_ml2_conf_ini(){
    prompt '/etc/neutron/plugins/ml2/ml2_conf.ini'
    append_section {$section_ml2,'type_drivers=flat,vlan',$ini_ml2_conf};
    append_section {$section_ml2,'tenant_network_types=',$ini_ml2_conf};
    append_section {$section_ml2,'mechanism_drivers=linuxbridge',$ini_ml2_conf};
    append_section {$section_ml2,'extension_drivers=port_security',$ini_ml2_conf};
    #【4】在你配置完ML2插件之后，删除可能导致数据库不一致的``type_drivers``项的值。
    append_section {$section_ml2_type_flat,'flat_networks=provider',$ini_ml2_conf};
    append_section {$section_securitygroup,'enable_ipset=True',$ini_ml2_conf};
}

#【4】配置Linuxbridge代理¶ #Linuxbridge代理为实例建立layer－2虚拟网络并且处理安全组规则。
function conf_linuxbridge_agent_ini(){
    prompt '/etc/neutron/plugins/ml2/linuxbridge_agent.ini'
    PROVIDER_INTERFACE_NAME=$(ifconfig |awk -F: NR==1'{print $1}');
    append_section {$section_linux_bridge,"physical_interface_mappings=provider:${PROVIDER_INTERFACE_NAME}",$ini_linuxbridge_agent}
    append_section {$section_vxlan,'enable_vxlan=False',$ini_linuxbridge_agent}
    append_section {$section_securitygroup,"enable_security_group=True",$ini_linuxbridge_agent};
    append_section {$section_securitygroup,"firewall_driver=neutron.agent.linux.iptables_firewall.IptablesFirewallDriver",$ini_linuxbridge_agent};
}

#(5)配置DHCP代代理 /etc/neutron/dhcp_agent.ini
function conf_dhcp_agent_ini(){
    append_section {$section_default,"interface_driver=linuxbridge",$ini_dhcp_agent}
    append_section {$section_default,'dhcp_driver=neutron.agent.linux.dhcp.Dnsmasq',$ini_dhcp_agent}
    append_section {$section_default,'enable_isolated_metadata=true',$ini_dhcp_agent}
}


function install_components(){
   yum -y install openstack-neutron openstack-neutron-ml2 openstack-neutron-linuxbridge ebtables

}
function network_public_main(){
install_components
conf_neutron_conf
conf_ml2_conf_ini
conf_linuxbridge_agent_ini
conf_dhcp_agent_ini
}
network_public_main