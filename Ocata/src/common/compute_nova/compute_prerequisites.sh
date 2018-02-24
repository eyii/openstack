#!/usr/bin/env bash
if [ -f '../api/common_function.sh' ]; then
  source '../api/common_function.sh'
  else
  source './api/common_function.sh'
fi
#openstack创建服务
#${1} =name  ${2}=description  ${3}=compute
function openstack_create_service(){
    openstack service create --name "${1}"' ' --description "${2}" ${3};
}
#创建nova服务
function openstack_create_nova(){
    list='nova placement';
    for i in ${list};
     do
     openstack_create_user_to_group {$i,service,admin};
     done
    openstack_create_service {nova,'OpenStack Compute',compute}
    openstack_loop_create_service_api_endpoint {'compute','8774/v2.1'}
}
#创建Placement服务
function openstack_create_placement_service(){
   openstack_create_service {'placement',"Placement API",'placement'};
   openstack_loop_create_service_api_endpoint {'placement',8778};
}


function grant_nova(){
list='nova_api nova nova_cell0';
for i in ${list};
 do
 mysql_auth_main {$i,'nova',$NOVA_DBPASS} ;
done
}
function compute_prerequisites_main(){
    #【1】创建数据库并授权：
    grant_nova
    if [ '$?'=0 ]; then
    echo '1'
    fi
    source ${admin_openrc_sh}
    #【2】nova服务
    openstack_create_nova;
    #【3】placement服务
    openstack_create_placement_service;

}