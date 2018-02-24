#!/bin/sh
source ./var.sh
prompt(){
    read -p "请回车==============开始=======$1"
	echo  "-------------------------------${1}-----------------------------------"
}

function install_start_service(){
	prompt "installservice---- ${1}"
	for svc in enable start status ; do systemctl ${svc} ${1}; done;
}
#${1}=keytone ${2}=${NOVA_DBPASS}
function install_mysql_auth(){
	mysql -u${mysql_username} -p${mysql_pwd} -e "CREATE DATABASE ${1};GRANT ALL PRIVILEGES ON ${1}.* TO'${1}'@'localhost' IDENTIFIED BY '${2}';GRANT ALL PRIVILEGES ON ${1}.* TO'${1}'@'%' IDENTIFIED BY '${2}';flush privileges;"
}

function install_db_conf(){
	prompt 'install_db_conf'
    if [ -f $1 ]; then
    rm -f $1;
    touch $1
    fi
    echo '[mysqld]' >> $1
    sed -i "/\[mysqld\]/a\bind-address = ${ipaddress}" $1
    sed -i "/\[mysqld\]/a\default-storage-engine = innodb" $1
    sed -i "/\[mysqld\]/a\innodb_file_per_table = on" $1
    sed -i "/\[mysqld\]/a\max_connections = 4096" $1
    sed -i "/\[mysqld\]/a\collation-server = utf8_general_ci" $1
    sed -i "/\[mysqld\]/a\character-set-server = utf8" $1
    cat $1
    install_start_service mariadb
    mysql_secure_installation #设置root密码（一直按回车，知道提示输入密码，输入两次后继续按回车）：
}

function install_memcached(){
	prompt 'install_memcached'
    yum -y install memcached python-memcached
    cp $1 /etc/sysconfig/memcached.bak
    sed -i "s/-l 127.0.0.1,::1/-l 127.0.0.1,::1,controller/g" $1 && cat $1
    install_start_service memcached
}
function install_section_database(){
	#[database]
    cp $1 ${1}'.bak'  && sed -i "/^\[database\]$/a\connection = mysql+pymysql://${2}:${3}@${CONTROLLER_HOST_NAME}/${2}" $1 && cat $1 |grep -5 '^\[database\]$'   #connection = mysql+pymysql://glance:GLANCE_DBPASS@controller/glance
}

function install_keystone(){
	prompt 'install_keystone'
    yum -y install openstack-keystone httpd mod_wsgi
	#[DEFAULT]
	ADMIN_TOKEN=$(openssl rand -hex 10)
    sed -i "/^\[DEFAULT\]$/a\admin_token = ${ADMIN_TOKEN}" $1 && cat $1 |grep -5 $
	#[database]
    cp $1 ${1}'.bak'  && sed -i "/^\[database\]$/a\connection = mysql+pymysql://keystone:${KEYSTONE_DBPASS}@${CONTROLLER_HOST_NAME}/keystone" $1 && cat $1 |grep -5 '^\[database\]$'
	#[token]
    sed -i "/^\[token\]$/a\provider = fernet" $1 && cat $1 |grep -5 '^\[token\]$'
    su -s /bin/sh -c "keystone-manage db_sync" keystone  #3Populate the Identity service database:
	#4Initialize Fernet key repositories:
    for svc in fernet_setup credential_setup ; do keystone-manage ${svc} --keystone-user keystone --keystone-group keystone ; done
	#5 Bootstrap the Identity service:
    keystone-manage bootstrap --bootstrap-password ${ADMIN_PASS} --bootstrap-admin-url ${url_35357} --bootstrap-internal-url ${url_5000} --bootstrap-public-url ${url_5000} --bootstrap-region-id RegionOne
}
#${1}=username  ${2}=--project ${3}=group
function install_create_user_to_group(){
    openstack user create --domain default  --password-prompt ${1}
    openstack role add --project ${2} --user ${1} ${3}
}
#${1}=project_name  ${2}=--description
function install_openstack_create_project(){
	openstack project create --domain default --description ${2} ${1}
}
function install_create_user(){
    install_openstack_create_project service "Service Project" && install_openstack_create_project demo "Demo Project"
    openstack role create user
    install_create_user_to_group demo demo user
}

#${1} =name  ${2}=description  ${3}=compute
function install_openstack_create_service(){
openstack service create --name ${1} --description "${2}"  ${3}
}
function install_openstack_auth(){
	openstack --os-auth-url http://${CONTROLLER_HOST_NAME}:${1}/v3 --os-project-domain-name default --os-user-domain-name default --os-project-name ${2} --os-username ${2} token issue
}

function install_openstack_endpoint_create(){
	 openstack endpoint create --region RegionOne image ${1} http://${CONTROLLER_HOST_NAME}:9292 #4创建镜像服务的 API 端点：
}
function install_openstack_glance_conf(){
	 install_section_database $1 'glance' ${GLANCE_DBPASS}
	#[keystone_authtoken]
	sed -i "/^\[keystone_authtoken\]$/a\auth_uri = ${url_5000} \nauth_url = ${url_35357} \nmemcached_servers = ${MemcachedServers}:11211 \nauth_type = password \nproject_domain_name = default \nuser_domain_name = default \nproject_name = service \nusername = glance \npassword = ${GLANCE_PASS}" $1
	#[paste_deploy]
	sed -i "/^\[paste_deploy\]$/a\flavor = keystone" $1
}
function append_section(){
    sed -i "/^${1}$/a\${2}" ${3}
}

#${1}=nova ${2}=port
function install_create_endpoint(){
	list="public internal admin" && for svc in ${list}; do openstack endpoint create --region RegionOne ${1} ${svc} http://${CONTROLLER_HOST_NAME}:${2}; done #4创建镜像服务的 API 端点：
}

#function--------------------------end-------------------------------------