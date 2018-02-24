#!/bin/sh
c37=$(hostname)
mysql_username='root'
mysql_pwd='1'
mysql_port='3306'
prompt(){
    read -p "请回车==============开始=======$1"
    CURRENT_PATH=$(pwd);
    echo "当前路径为==========$CURRENT_PATH"
    history -c
    unset CURRENT_PATH;
    clear
}
prompt 'OpenStack Ocata 安装（二）安装身份验证（Keystone）服务 http://blog.csdn.net/chenvast/article/details/71036117'
#OpenStack标识服务为管理身份验证、授权和服务目录提供了单一的集成点。标识服务通常是用户与用户交互的第一个服务

prompt ' 1创建该服务的数据库和数据库管理账户：'
install_rpm(){
mysql -u$mysql_username -p$mysql_pwd -e "CREATE DATABASE keystone;GRANT ALL PRIVILEGES ON keystone.* TO'keystone'@'localhost' IDENTIFIED BY 'keystone';GRANT ALL PRIVILEGES ON keystone.* TO'keystone'@'%' IDENTIFIED BY 'keystone';"
}
install_rpm
 
 
prompt ' 2配置keystone的配置文件'
install_keystone(){
cp $1 ${1}'.bak' #在controller#
sed -i "#\[database\]#a\connection = mysql\+pymysql:\/\/keystone\:keystone@${c37}\/keystone" $1 #添加keystone.conf [database]
sed -i "#\[token\]#a\provider = fernet#" $1
su -s /bin/sh -c "keystone-managedb_sync" keystone #同步（写入）数据库
keystone-manage fernet_setup--keystone-user keystone --keystone-group keystone #初始化密钥存储库：
keystone-manage credential_setup--keystone-user keystone --keystone-group keystone
keystone-manage bootstrap--bootstrap-password admin \ 
--bootstrap-admin-url http://${c37}:35357/v3/ --bootstrap-internal-url http://${c37}:5000/v3/ 
--bootstrap-public-url http://${c37}:5000/v3/ --bootstrap-region-id RegionOne  
}
install_keystone '/etc/keystone/keystone.conf'



prompt ' 3安装httpd服务：'
install_keystone(){
ServerName controller #controller#
ln -s/usr/share/keystone/wsgi-keystone.conf /etc/httpd/conf.d/ #把keystone的虚拟主机文件链接的http的配置目录下
systemctl enable httpd.service #开机自启动和启动服务
systemctl restart httpd.service
}
install_keystone '/etc/httpd/conf/httpd.conf'

prompt '4keystone的创建以及验证操作：'
install_keystone(){
配置管理用户的环境变量
export OS_USERNAME=admin #controller#

export OS_PASSWORD=admin

export OS_PROJECT_NAME=admin

export OS_USER_DOMAIN_NAME=Default

export OS_PROJECT_DOMAIN_NAME=Default

export OS_AUTH_URL=http://controller:35357/v3

export OS_IDENTITY_API_VERSION=3



 
}
install_keystone '/etc/httpd/conf/httpd.conf'

prompt '5创建一个域、项目、用户和角色：'
install_keystone(){
openstack project create --domain default --description "Service Project"service #controller# 创建一个域、项目、用户和角色：
openstack project create --domain default --description "Demo Project" demo
openstack user create --domain default --password-prompt demo #下一步输入创建的demo用户的密码
openstack role create user
openstack role add --project demo --userdemo user #controller# 将用户角色添加到演示项目和用户:
#编辑 的/etc/keystone/keystone-paste.ini文件，并从[public_api]、[admin_api]、[api_v3]段删除admin_token_auth参数。禁止临时认证机制。

}
install_keystone '/etc/httpd/conf/httpd.conf'



验证操作

controller#

unset OS_AUTH_URL OS_PASSWORD
openstack --os-auth-url http://controller:35357/v3 --os-project-domain-name default--os-user-domain-name default --os-project-name admin --os-username admintoken issue #输入admin用户的密码，正确会有输出。
openstack --os-auth-url http://controller:5000/v3 --os-project-domain-name default--os-user-domain-name default --os-project-name demo --os-username demotoken issue #输入demo用户的密码，正确会有输出。


创建客户机环境OpenStack脚本（admin和demo用户的环境脚本）：

controller#

vi admin.sh

export OS_PROJECT_DOMAIN_NAME=Default

export OS_USER_DOMAIN_NAME=Default

export OS_PROJECT_NAME=admin

export OS_USERNAME=admin

export OS_PASSWORD=admin

export OS_AUTH_URL=http://controller:35357/v3

export OS_IDENTITY_API_VERSION=3

export OS_IMAGE_API_VERSION=2

 

vi demo.sh

export OS_PROJECT_DOMAIN_NAME=Default

export OS_USER_DOMAIN_NAME=Default

export OS_PROJECT_NAME=demo

export OS_USERNAME=demo

export OS_PASSWORD=demo

export OS_AUTH_URL=http://controller:5000/v3

export OS_IDENTITY_API_VERSION=3

export OS_IMAGE_API_VERSION=2

 

使用source命令导入脚本里的环境变量以及查看keystone认证详情

controller#

source admin
openstack token issue