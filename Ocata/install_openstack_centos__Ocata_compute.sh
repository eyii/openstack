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
echo ‘compute’ >/etc/hostname
sed -i '$a\192.168.1.137 controller'  /etc/hosts
sed -i '$a\192.168.1.138 compute'  /etc/hosts
yum install centos-release-openstack-ocata -y
yum upgrade -y
}
install_rpm


prompt '   在compute yum包安装完毕'
install_packstack(){
yum install openstack-nova-computeopenstack-neutron-linuxbridge ebtables ipset -y
}
install_packstack


prompt ' 三：一键自动安装'
install_packstack(){
sudo yum install -y openstack-packstack
}
install_packstack

prompt '  安装完毕，可以通过OpenStack的网络管理接口Horizon进行访问，地址如：http://$YOURIP/dashboard  ，用户名为admin，密码可以在/root/ 下的keystonerc_admin文件中找到到。'
install_openstack(){
packstack --allinone
cat /root/keystonerc_admin
}
install_openstack


# 后续工作，可以添加实例，自行进行测试。参考网站：http://openstack.redhat.com/Running_an_instance
# 当一切就绪，还可以添加节点，但需要进行配置，具体参考： http://openstack.redhat.com/Adding_a_compute_node
# 网络管理配置，具体参考：http://openstack.redhat.com/Floating_IP_range