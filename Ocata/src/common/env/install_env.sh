#!/usr/bin/env bash
if [ -f '../api/common_function.sh' ]; then
  source '../api/common_function.sh'
  else
  source './api/common_function.sh'
fi
#1环境 https://docs.openstack.org/ocata/install-guide-rdo/environment.html
#Security
#Host networking
#Network Time Protocol (NTP)
#OpenStack packages
#SQL database
#Message queue
#Memcached
#hosts
function install_hosts(){
    del_row {'^192',/etc/hosts}
    replace {'SELINUX=enforcing','SELINUX=disabled','/etc/selinux/config'}
	setenforce 0
    append_end_hosts {$ipaddress,'controller'}
    append_end_hosts {'192.168.172.129','compute'}
	ping -c 3 controller
	cat /etc/hosts
}
#ntp chrony
function install_ntp(){
  remove_file ${chrony_conf}
  yum_reinstall {'chrony',}
  del_row {'^server',$chrony_conf}
  echo 'allow 192.168.172.0/24' >> ${chrony_conf}
  echo "server ${CONTROLLER_HOST_NAME} iburst" >> ${chrony_conf}
  install_start_service {'chronyd',}
}

#/etc/my.cnf.d/openstack.cnf
function install_db_conf(){
	prompt 'install_db_conf'
      if [ -f $1 ]; then
    rm -f $1;
    touch $1
    fi
    echo '' >> $1
    #${1}===mysql_openstack_conf=
echo "
[mysqld]
bind-address = ${ipaddress}
default-storage-engine = innodb 
innodb_file_per_table = on 
max_connections = 4096
collation-server = utf8_general_ci 
character-set-server = utf8" >> ${openstack_conf}
	cat $1
    install_start_service {mariadb,}
    mysql_secure_installation #设置root密码（一直按回车，知道提示输入密码，输入两次后继续按回车）：
    mysql_auth_main {'keytone','keytone',$KEYSTONE_DBPASS}
}
#mariadb
function install_mariadb(){
    remove_file ${openstack_conf};
    yum_reinstall {'mariadb mariadb-server python2-PyMySQL',};
    install_db_conf ${openstack_conf};
}
#rabbitmq_server
function install_rabbitmq_server(){
    man rabbitmqctl | grep 'SYNOPSIS'
    if [ $? = 0 ];then
    rabbitmqctl stop
    rabbitmqctl reset
    fi

    yum_reinstall {'rabbitmq-server',};
    install_start_service {'rabbitmq-server',} ;
    rabbitmqctl add_user openstack ${RABBIT_PASS} ;
    rabbitmqctl set_permissions openstack ".*" ".*" ".*"
    install_start_service {'rabbitmq-server',} ;
}
#开放端口
function install_firewall_cmd(){
  for i in 5000 35357 3306 11211 9292 8774 8778 9696; do firewall-cmd --add-port=${i}/tcp --permanent; done;
}
#memcached
function install_memcached(){
    if [ -f ${file_memcached} ];then
    sed -i '/^OPTIONS/d' ${file_memcached};
    fi
    yum_reinstall {'memcached python-memcached',}
    cp -u ${file_memcached} ${file_memcached}'.bak'
    sed -i "s/-l 127.0.0.1,::1/-l 127.0.0.1,::1,controller/g"  ${file_memcached} && cat $1
    install_start_service {"memcached",}
}
#入口
function main_environment(){
	prompt ' 一Environment'
	rpm --import /etc/pki/rpm-gpg/RPM*
	rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
    prompt '#hosts'
    install_hosts;
    prompt ' #NTP'
    install_ntp;
    prompt ' #自动更新'
    #service yum-updatesd stop && service yum-updatesd status && chkconfig –level 35 yum-updatesd off
    #yum provides '*/applydeltarpm'
	# yum install deltarpm
	prompt ' #安装包'
	yum_reinstall {'centos-release-openstack-ocata',}
	yum -y upgrade
	yum_reinstall {'python-openstackclient openstack-selinux openstack-status deltarpm',}
    prompt ' #SQL database'
    install_mariadb
    prompt '#rabbitmq-server'
    install_rabbitmq_server;
    prompt '#Memcached'
    install_memcached ${file_memcached}
    prompt '#port'
    install_firewall_cmd;
}


