#!/usr/bin/env bash

prompt '5 网络服务';
function install_networking(){
echo 'dddd'
}

function include(){
for i in ${1}*.sh ; do
    if [ -r "$i" ]; then
    source "$i"
    fi
done
}
