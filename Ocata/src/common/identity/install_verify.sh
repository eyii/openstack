#!/usr/bin/env bash
if [ -f '../api/common_function.sh' ]; then
  source '../api/common_function.sh'
  else
  source './api/common_function.sh'
fi

function vertify(){
unset OS_AUTH_URL OS_PASSWORD
config_administrator_account
openstack_auth {$url_35357_v3,'admin'}
config_administrator_account
openstack_auth {$url_5000_v3,'demo'}
}
vertify