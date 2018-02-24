#!/usr/bin/env bash
if [ -f '../api/common_function.sh' ]; then
  source '../api/common_function.sh'
  else
  source './api/common_function.sh'
fi
function vertify_opertion(){
     source ${admin_openrc_sh}
     yum -y install wget
     img_file='cirros-0.3.4-x86_64-disk.img';
     remove_file {$img_file,}
	 wget "http://download.cirros-cloud.net/0.3.4/${img_file}"
	 prompt '使用 QCOW2 磁盘格式， bare 容器格式上传镜像到镜像服务并设置公共可见，这样所有的项目都可以访问它：'
	 openstack image create "cirros"  --file ${img_file} --disk-format qcow2 --container-format bare --public
	 openstack image list
}