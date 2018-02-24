#!/usr/bin/env bash

if [ -f '../api/common_function.sh' ]; then
  source '../api/common_function.sh'
  else
  source './api/common_function.sh'
fi


:<<comment
https://docs.openstack.org/ocata/install-guide-rdo/glance-install.html
Image service overview
Install and configure
    Prerequisites
    Install and configure components
    Finalize installation
Verify operation
comment


function main_image(){
		read -p '
		#【1】建glance库表：
		#【2】先决条件 要创建服务证书，完成这些步骤： 创建 glance 用户：
		#【3】安全并配置组件 #glance-api.conf && glance-registry.conf
		#【4】写入镜像服务数据库：
	    #【5】验证操作
		' number
		case ${number} in
            1)
             mysql_auth_main {'glance','glance',$GLANCE_DBPASS} ;;
            2)
            source ./image/install_create_glance_user.sh
            create_glance_user_main;;
            3)
             source ./image/install_glance_x_conf.sh
             install_glance_x_conf  | tee -a /var/log/openstack_install_Image.log;;
            4)
            source ./image/install_glance_sync.sh;;
            5)
            source ./image/install_vertify.sh
	        vertify_opertion;;
	   esac
}
