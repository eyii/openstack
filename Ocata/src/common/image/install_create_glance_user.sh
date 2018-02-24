#!/usr/bin/env bash
if [ -f '../api/common_function.sh' ]; then
  source '../api/common_function.sh'
  else
  source './api/common_function.sh'
fi
#. admin-openrc
#openstack user create --domain default --password-prompt glance
#openstack role add --project service --user glance admin
#openstack service create --name glance  --description "OpenStack Image" image
#openstack endpoint create --region RegionOne  image public http://controller:9292
#openstack endpoint create --region RegionOne image internal http://controller:9292
#openstack endpoint create --region RegionOne image admin http://controller:9292


#循环创端点pia
#${1}=nova ${2}=port
function openstack_loop_create_service_api_endpoint(){
    list="public internal admin";
	for svc in ${list}; do openstack_endpoint_create {$1,$svc,$2}; done #4创建镜像服务的 API 端点：
}
#创端点endpoint
#${1}=image ${2}=public ${3}=7783
function openstack_endpoint_create(){
     openstack endpoint create --region RegionOne "${1}"' ' ${2} http://${CONTROLLER_HOST_NAME}:${3};
}
#${1}=username  ${2}=--project ${3}=group
function openstack_create_user_to_group(){
    openstack user create --domain default  --password-prompt ${1};
    openstack role add --project ${2} --user ${1} ${3};
}
#openstack创建服务
#${1} =name  ${2}=description  ${3}=compute
function openstack_create_service(){
    openstack service create --name "${1}"' ' --description "${2}" ${3};
}


function create_glance_user_main(){
    source ${admin_openrc_sh}
    prompt ' #添加 admin 角色到 glance 用户和 service 项目上。'
    openstack_create_user_to_group {'glance','service','admin'}
    prompt '#创建glance服务实体：'
    openstack_create_service {glance,'OpenStack Image',image}
    prompt '#循环创建镜像服务api端点'
    openstack_loop_create_service_api_endpoint {image,9292}
}
