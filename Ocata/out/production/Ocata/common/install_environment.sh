#!/bin/sh

#1环境
function install_environment(){
	prompt ' 一Environment'
    #hosts
    sed -i '$a'${ipaddress}' controller' /etc/hosts && sed -i '$a\192.168.172.129 compute'  /etc/hosts && cat /etc/hosts && ping -c 4 controller
    #NTP
    yum  -y install chrony && echo 'allow 192.168.172.0/24' >> $1 && sed -i "/^server/d" $1 && echo "server ${CONTROLLER_HOST_NAME} iburst" >> $1 && install_start_service chronyd
    #自动更新
    #service yum-updatesd stop && service yum-updatesd status && chkconfig –level 35 yum-updatesd off
    #OpenStack repository
    #yum provides '*/applydeltarpm'
	# yum install deltarpm
	yum -y install centos-release-openstack-ocata && yum -y upgrade && yum -y install python-openstackclient openstack-selinux openstack-status deltarpm
     #SQL database
    yum -y install mariadb mariadb-server python2-PyMySQL && install_db_conf '/etc/my.cnf.d/openstack.cnf'
    #rabbitmq-server
    yum -y install rabbitmq-server && install_start_service rabbitmq-server && rabbitmqctl add_user openstack ${RABBIT_PASS} && rabbitmqctl set_permissions openstack ".*" ".*" ".*"
    #Memcached
    install_memcached '/etc/sysconfig/memcached'
    #port
    for port in 5000 35357 3306 11211 9292 8774; do firewall-cmd --add-port=${port}/tcp --permanent; done;
	rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
}