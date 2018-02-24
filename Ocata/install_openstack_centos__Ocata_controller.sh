#!/bin/sh

prompt(){
    read -p "请回车==============开始=======$1"
    CURRENT_PATH=$(pwd);
    echo "当前路径为==========$CURRENT_PATH"
    history -c
    unset CURRENT_PATH;
    clear
}
prompt 'OpenStack Ocata 安装（一）环境准备 http://blog.csdn.net/chenvast/article/details/71036033'


prompt ' 一：安装RDO软件'
install_rpm(){
sed -i '$a\192.168.1.137 c37' /etc/hosts
sed -i '$a\192.168.1.138 c38' /etc/hosts
#ntp
timedatectl set-timezone Asia/Shanghai
yum install ntp -y
systemctl enable ntpd
systemctl start ntpd
ntpdate -u cn.pool.ntp.org
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
setenforce 0
getenforce
yum update -y
yum install centos-release-openstack-ocata -y
yum upgrade -y
yum repolist
}
install_rpm
 


prompt '2 controller# 安装包'
install_openstack_yum(){
rm -f /var/log/yum.log
yum install -y python-openstackclient  mariadb mariadb-server python2-PyMySQL 
yum install -y rabbitmq-server memcached python-memcached openstack-keystone httpd mod_wsgiopenstack-glance 
yum install -y openstack-nova-api openstack-nova-conductor openstack-nova-consoleopenstack-nova-novncproxy 
yum install -y openstack-nova-scheduleropenstack-nova-placement-api openstack-neutron openstack-neutron-ml2 
yum install -y openstack-neutron-linuxbridge ebtables openstack-dashboard
cat /var/log/yum.log
}
install_openstack_yum


#配置数据库：
prompt '3 #配置数据库：'
install_db_conf(){
if [ -f $1 ]; then
rm -f $1;
touch $1
fi
echo '[mysqld]' >> $1
ipaddress=$(ifconfig | sed -n 2p | awk '{print $2}')
sed -i "/\[mysqld\]/a\bind-address = "$ipaddress $1
sed -i "/\[mysqld\]/a\default-storage-engine = innodb" $1
sed -i "/\[mysqld\]/a\innodb_file_per_table = on" $1
sed -i "/\[mysqld\]/a\max_connections = 4096" $1
sed -i "/\[mysqld\]/a\collation-server = utf8_general_ci" $1
sed -i "/\[mysqld\]/a\character-set-server = utf8" $1
cat $1
firewall-cmd --add-port=3306/tcp --permanent
firewall-cmd --reload
systemctl enable mariadb
systemctl start mariadb
#设置root密码（一直按回车，知道提示输入密码，输入两次后继续按回车）：
mysql_secure_installation
}
install_db_conf '/etc/my.cnf.d/openstack.cnf'


prompt '4、安装RabbitMQ：'
install_rabbitmq(){
systemctl enable rabbitmq-server
systemctl start rabbitmq-server
#设置rabbitmq的账户密码和权限（账户密码都为openstack）
rabbitmqctl add_user openstack openstack
rabbitmqctl set_permissions openstack ".*" ".*" ".*"
}
install_rabbitmq



prompt '4、安装memcached'
install_rabbitmq(){
cp $1 /etc/sysconfig/memcached.bak
host=$(hostname)
sed -i "s/-l 127.0.0.1,::1/-l 127.0.0.1,::1,${host}/g" $1
cat $1
firewall-cmd --add-port=11211/tcp --permanent
firewall-cmd --reload
systemctl enable memcached
systemctl start memcached
systemctl status memcached
}
install_rabbitmq '/etc/sysconfig/memcached'



 
