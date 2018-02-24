#!/usr/bin/env bash
if [ -f '../api/common_function.sh' ]; then
  source '../api/common_function.sh'
  else
  source './api/common_function.sh'
fi

function config_mysql(){
 # /etc/nova/nova.conf
    append_section {$section_default,'enabled_apis=osapi_compute,metadata',$nova_conf};
    #[database] connection=mysql+pymysql://nova:NOVA_DBPASS@controller/nova
    openstack_append_section_connection {$section_database,nova,$NOVA_DBPASS,$nova_conf}
    #[api_database] connection=mysql+pymysql://nova:NOVA_DBPASS@controller/nova_api
    append_section {$section_api_database,"connection=mysql+pymysql://nova:${NOVA_DBPASS}@${CONTROLLER_HOST_NAME}/nova_api",$nova_conf};

}
function  config_compute_rabbit(){
    #[DEFAULT] transport_url=rabbit://openstack:RABBIT_PASS@controller
    append_section {$section_default,"transport_url=rabbit://openstack:${RABBIT_PASS}@${CONTROLLER_HOST_NAME}",$nova_conf};
}
#configure Identity service access:
function configure_compute_identity_access(){

    #[api] auth_strategy=keystone
    append_section {$section_api,'auth_strategy=keystone',$nova_conf};
    #[keystone_authtoken]
    config_section_keytone_authtoken {'nova',${NOVA_PASS},$nova_conf}
}


function config_compute_anagement_interface_ip(){
    #In the [DEFAULT] section, configure the my_ip option to use the management interface IP address of the controller node:
    #[DEFAULT] my_ip=10.0.0.11
    append_section {$section_default,'my_ip='${ipaddress},$nova_conf};
    #[DEFAULT] use_neutron=True firewall_driver=nova.virt.firewall.NoopFirewallDriver
    append_section {$section_default,'use_neutron=True \nfirewall_driver=nova.virt.firewall.NoopFirewallDriver',$nova_conf};
}
function config_section_placment(){
    # [placement] =>the Placement API: 注释掉[placement]节里的其他项
    append_section {$section_placement,"auth_url=${url_35357_v3}",$nova_conf};
    append_section {$section_placement,"auth_type=password",$nova_conf};
    append_section {$section_placement,"project_domain_name=Default",$nova_conf};
    append_section {$section_placement,"user_domain_name=Default",$nova_conf};
    append_section {$section_placement,"os_region_name=RegionOne",$nova_conf};
    append_section {$section_placement,"project_name=service",$nova_conf};
    append_section {$section_placement,"username=placement",$nova_conf};
    append_section {$section_placement,"password=${PLACEMENT_PASS}",$nova_conf};
}
config_compute_httpd(){
echo '
<Directory /usr/bin>
    <IfVersion >= 2.4>
      Require all granted
    </IfVersion>
    <IfVersion < 2.4>
     Order allow,deny
     Allow from all
    </IfVersion>
</Directory>
' >> /etc/httpd/conf.d/00-nova-placement-api.conf
    systemctl restart httpd
}
config_compute_populate_database(){
    #Populate the nova-api database:
    su -s /bin/sh -c "nova-manage api_db sync" nova
    #注册cell0数据库
    su -s /bin/sh -c "nova-manage cell_v2 map_cell0" nova
    #Create the cell1 cell:

    su -s /bin/sh -c "nova-manage cell_v2 create_cell --name=cell1 --verbose" nova
    #109e1d4b-536a-40d0-83c6-5f121b82b650
    #Populate the nova database:

    su -s /bin/sh -c "nova-manage db sync" nova

    #验证nova cell0 和cell1是否被注册正确
    nova-manage cell_v2 list_cells

}

function start_nova_service(){
systemctl enable openstack-nova-api.service openstack-nova-consoleauth.service openstack-nova-scheduler.service  openstack-nova-conductor.service openstack-nova-novncproxy.service
systemctl start openstack-nova-api.service openstack-nova-consoleauth.service openstack-nova-scheduler.service openstack-nova-conductor.service openstack-nova-novncproxy.service
systemctl status openstack-nova-api.service openstack-nova-consoleauth.service openstack-nova-scheduler.service  openstack-nova-conductor.service openstack-nova-novncproxy.service

}
function config_enable_vncserver(){
    # [vnc] enabled=true vncserver_listen=$my_ip vncserver_proxyclient_address=$my_ip
    append_section {$section_vnc,'enabled=true',$nova_conf};
    append_section {$section_vnc,'vncserver_listen=$my_ip',$nova_conf};
    append_section {$section_vnc,'vncserver_proxyclient_address=$my_ip',$nova_conf};
}
function config_glance(){
 # [glance] 配置 the location of the镜像服务的API:
    # [glance] api_servers=http://controller:9292
    append_section {$section_glance,"api_servers=${url_9292}",$nova_conf};
}
function config_lock_path(){
    #[oslo_concurrency] lock_path=/var/lib/nova/tmp
    append_section {$section_oslo_concurrency,'lock_path=/var/lib/nova/tmp',$nova_conf};
}
function yum_install_openstack_nova(){
     for svc in ${1};do yum -y install openstack-nova-${svc}; done
}

     #【4】改配置/etc/nova/nova.conf &&
function compute_configure_controller_node_main(){
    #【1】Install the packages:
    yum_install_openstack_nova {'api conductor console novncproxy scheduler placement-api',}
    #【2】Edit the /etc/nova/nova.conf
    config_mysql
    config_compute_rabbit
    configure_compute_identity_access
    config_compute_anagement_interface_ip
    #
    config_enable_vncserver
    config_glance
    config_lock_path
    config_section_placment

    #【3】/etc/httpd/conf.d/00-nova-placement-api.conf:
    config_compute_httpd

    #【4】Register the cell0 database: 填充数据库
    config_compute_populate_database
    #【5】启动 Compute services
    start_nova_service
}

