#!/usr/bin/env bash
#声明变量

function global_args(){
    #Security https://docs.openstack.org/ocata/install-guide-rdo/environment-security.html
    export ADMIN_PASS='1';
    export CINDER_DBPASS='1';
    export CINDER_PASS='1';
    export DASH_DBPASS='1';
    export DEMO_PASS='1';
    export GLANCE_DBPASS='1';
    export GLANCE_PASS='1';
    export KEYSTONE_DBPASS='1';
    export METADATA_SECRET='1';
    export NEUTRON_DBPASS='1';
    export NEUTRON_PASS='1';
    export NOVA_DBPASS='1';
    export NOVA_PASS='1';
    export PLACEMENT_PASS='1';
    export RABBIT_PASS='1';
    #section
    export section_api='^\[api\]$';
    export section_api_database='^\[api_database\]$';
    export section_default='^\[DEFAULT\]$';
    export section_database='^\[database\]$';
    export section_mysql='^\[mysqld\]$';
    export section_token='^\[token\]$';
    export section_keystone_authtoken='^\[keystone_authtoken\]$';
    export section_nova='^\[nova\]$';
    export section_vnc='^\[vnc\]$';
    export section_glance='^\[glance\]$';
    export section_oslo_concurrency='^\[oslo_concurrency\]$';
    export section_ml2='^\[ml2\]$';
    export section_ml2_type_flat='^\[ml2_type_flat\]$';
    export section_placement='^\[placement\]$';
    export section_linux_bridge='^\[linux_bridge\]$';
    export section_vxlan='^\[vxlan\]$';
    export section_securitygroup='^\[securitygroup\]$';
    export section_neutron='^\[neutron\]$';
    export section_glance_store='^\[glance_store\]$'
    export section_paste_deploy='^\[paste_deploy\]$';
    export section_apache='^#ServerName.*';
    #conf
    export httpdconf='/etc/httpd/conf/httpd.conf';
    export keystone_conf='/etc/keystone/keystone.conf';
    export neutron_conf='/etc/neutron/neutron.conf';
    export nova_conf='/etc/nova/nova.conf';
    export registry_conf='/etc/glance/glance-registry.conf'
    export api_conf='/etc/glance/glance-api.conf';
    export chrony_conf='/etc/chrony.conf';
    export openstack_conf='/etc/my.cnf.d/openstack.cnf';
    export wsgi_keystone_conf='/usr/share/keystone/wsgi-keystone.conf'
    export httpd_wsgi_keytone_conf='/etc/httpd/conf.d/wsgi-keystone.conf'
    #ini
    export ini_linuxbridge_agent='/etc/neutron/plugins/ml2/linuxbridge_agent.ini';
    export ini_dhcp_agent='/etc/neutron/dhcp_agent.ini';
    export ini_ml2_conf='/etc/neutron/plugins/ml2/ml2_conf.ini'
    export ini_metadata_agent='/etc/neutron/metadata_agent.ini'
    export ini_keystone_paste='/etc/keystone/keystone-paste.ini'
     #sh
    export admin_openrc_sh='/root/admin-openrc.sh';
    export demo_openrc_sh='/root/demo-openrc.sh';
     #system
    export mysql_port='3306';
    export host=$(hostname);
    export OS_SERVICE_TOKEN=1;
    #$(openssl rand -hex 10);
    export ipaddress=$(ifconfig | sed -n 2p | awk '{print $2}');
    export CONTROLLER_HOST_NAME='controller';
    export MemcachedServers=${CONTROLLER_HOST_NAME};
    export dir_keystone='/usr/share/keystone/';
    export file_memcached='/etc/sysconfig/memcached';
    #url
    export url_35357_v3="http://${CONTROLLER_HOST_NAME}:35357/v3/";
    export url_5000_v3="http://${CONTROLLER_HOST_NAME}:5000/v3/";
    export url_35357="http://${CONTROLLER_HOST_NAME}:35357";
    export url_5000="http://${CONTROLLER_HOST_NAME}:5000";
    export url_9696="http://${CONTROLLER_HOST_NAME}:9696";
    export url_9292="http://${CONTROLLER_HOST_NAME}:9292";
 #other
    export OS_PROJECT_DOMAIN_NAME=Default
    export mysql_username='root';
    export mysql_pwd='1';
    #openstack
    export OS_SERVICE_ENDPOINT=
    export ADMIN_TOKEN=1
    #$(openssl rand -hex 10);
    mkdir -p /var/log/ops

    #dashboard

}
global_args;

#提示暂停函数
function prompt(){
    read -p "=========$1============";
     clear

}

#hosts
#${1}=ipaddress ${2}=pcname
function append_end_hosts(){
  sed -i '$a'"${1}"' '${2} /etc/hosts
}

function del_row(){
    sed -i "/${1}/d" ${2}
}
function replace(){
    sed -i "s/${1}/${2}/g" $3
}

#启动服务
function install_start_service(){
	prompt "installservice---- ${1}"
	for svc in enable start status ; do systemctl ${svc} ${1}; done
}
function mysql_create_database(){
	mysql -u${mysql_username} -p${mysql_pwd} -e "CREATE DATABASE ${1};"
	mysql -u${mysql_username} -p${mysql_pwd} -e "exit"
}

#${1}=库名,用户名 ${2}=username $3=password
function mysql_grant_user(){
	mysql -u${mysql_username} -p${mysql_pwd} -e "GRANT ALL PRIVILEGES ON ${1}.* TO'${2}'@'localhost' IDENTIFIED BY '${3}';"
    mysql -u${mysql_username} -p${mysql_pwd} -e "GRANT ALL PRIVILEGES ON ${1}.* TO'${2}'@'%' IDENTIFIED BY '${3}';"
	mysql -u${mysql_username} -p${mysql_pwd} -e "flush privileges;"
	mysql -u${mysql_username} -p${mysql_pwd} -e "exit"
}
#${1}=keytone ${2}=username $3=${NOVA_DBPASS}
function mysql_auth_main(){
    mysql_create_database ${1};
    mysql_grant_user {$1,$2,$3}
}
function yum_reinstall(){
    if [ ! -d '~/soft' ]; then
            mkdir -p ~/soft
    fi
     for i in ${1};
     do
        prompt {"yum_remov====${1}=====",}
        yum -y remove ${i}
        prompt "yum_install=========${1}======="
        yum -y install ${i} --downloaddir=/soft/;
      done
}
function remove_file(){
    if [ -f ${1} ]; then
    rm -f ${1}
    fi
}
# ${1}=username  ${2}==password $3=filename
function openstack_append_section_database_connection(){
	cp ${3} ${3}'.bak';
	append_section {$section_database,"connection=mysql+pymysql://${1}:${2}@${CONTROLLER_HOST_NAME}/${1}",$3};
}
#${1}==section ${2}=username  ${3}==password  $4=filename
function openstack_append_section_connection(){
	cp -u ${4} ${4}'.bak';
	append_section {$1,"connection=mysql+pymysql://${2}:${3}@${CONTROLLER_HOST_NAME}/${2}",$4};
}
#创用户加组
#${1}=username  ${2}=--project ${3}=group
function openstack_create_user_to_group(){
    openstack user create --domain default  --password-prompt ${1};
    openstack role add --project "${2}"' ' --user "${1}"' ' ${3};
}
#创工程
#${1}=project_name  ${2}=--description
function openstack_create_project(){
	openstack project create --domain default --description "${2}"'' ${1};
}
function openstack_create_user(){
    openstack_create_project {service,'Service Project'};
    openstack_create_project {demo,'Demo Project'};
    openstack role create user;
    openstack_create_user_to_group {demo,demo,user};
}
#openstack创建服务
#${1} =name  ${2}=description  ${3}=compute
function openstack_create_service(){
    openstack service create --name ${1} --description ${2}' ' ${3};
}
#openstack授权 $1=url $2=--os-project-name
function openstack_auth(){
	openstack --os-auth-url ${1} --os-project-domain-name default --os-user-domain-name default --os-project-name ${2} --os-username ${2} token issue;
}
#创端点endpoint
#${1}=image ${2}=public ${3}=7783
function openstack_endpoint_create(){
     openstack endpoint create --region RegionOne ${1} ${2} http://${CONTROLLER_HOST_NAME}:${3};
}
#搜索section
#${2}=grep_name ${3}=file_path
function search(){
cat ${2} | grep -2 ${1}
}
#${1}=search  ${2}=target ${3}=filename
function append_section(){
    cp ${3} ${3}'.bak';
    sed -i "/${1}/a""${2}"' ' ${3} && search {$1,$3}
}
#循环创端点pia
#${1}=nova ${2}=port
function openstack_loop_create_service_api_endpoint(){
    list="public internal admin";
	for svc in ${list}; do openstack_endpoint_create {$1,$svc,$2}; done #4创建镜像服务的 API 端点：
}

function is_root(){
if [ "$(id -u)" != "0" ]; then
   echo "You need to be 'root' dude." 1>&2
   exit 1
fi
}
#auth_uri = http://controller:5000 \nauth_url = http://controller:35357 \nmemcached_servers = controller:11211 \nauth_type = password \nproject_domain_name = default \nuser_domain_name = default \nproject_name = service \nusername = neutron \npassword = NEUTRON_PASS
 #   append_section {$section_keystone_authtoken,"auth_uri = ${url_5000} \nauth_url = ${url_35357} \nmemcached_servers = ${MemcachedServers}:11211

#$1=username $2=password $3=file
function config_section_keytone_authtoken(){
    append_section {$section_keystone_authtoken,"auth_uri=${url_5000}",$3} ;
    append_section {$section_keystone_authtoken,"auth_url=${url_35357}",$3}
    append_section {$section_keystone_authtoken,"memcached_servers=${MemcachedServers}:1121",$3}
    append_section {$section_keystone_authtoken,"auth_type=password",$3}
    append_section {$section_keystone_authtoken,"project_domain_name=default",$3}
    append_section {$section_keystone_authtoken,"user_domain_name=default",$3}
    append_section {$section_keystone_authtoken,"project_name=service",$3}
    append_section {$section_keystone_authtoken,"username=${1}",$3}
    append_section {$section_keystone_authtoken,"password=${2}",$3}
}

function download_rpm(){
yum -y install yum-downloadonly
yum install --downloadonly --downloaddir="${2}"' ' ${1}

}


function config_administrator_account(){
export OS_USERNAME=admin
export OS_PASSWORD=${ADMIN_PASS}
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=${url_35357_v3}
export OS_IDENTITY_API_VERSION=3
}

function conf_section_access(){
    append_section {$3,"auth_url=${url_35357}",$4}
    append_section {$3,"auth_type=password",$4}
    append_section {$3,"project_domain_name=default",$4}
    append_section {$3,"user_domain_name=default",$4}
    append_section {$3,"project_name=service",$4}
    append_section {$3,"username=${1}",$4}
    append_section {$3,"password=${2}",$4}
    append_section {$3,"region_name=RegionOne",$4}
}