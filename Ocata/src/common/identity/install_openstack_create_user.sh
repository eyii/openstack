#!/usr/bin/env bash
if [ -f '../api/common_function.sh' ]; then
  source '../api/common_function.sh'
  else
  source './api/common_function.sh'
fi

#【4】Create a domain, projects, users, and roles
#openstack project create --domain default  --description "Service Project" service
#openstack project create --domain default --description "Demo Project" demo
#openstack user create --domain default --password-prompt demo
#openstack role create user
#openstack role add --project demo --user demo user'

function openstack_create_project(){
	openstack project create --domain default --description "${2}"' ' ${1};
}

function openstack_create_user(){
    config_administrator_account
    openstack_create_project {service,'Service Project'};
    openstack_create_project {demo,'Demo Project'};
    openstack role create user;
    openstack_create_user_to_group {demo,demo,user};
}
