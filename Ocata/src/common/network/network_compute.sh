#!/usr/bin/env bash
if [ -f '../api/common_function.sh' ]; then
  source '../api/common_function.sh'
  else
  source './api/common_function.sh'
fi
#compute=========================================================
function install_the_components(){
echo 1

}
function configure_the_common_component(){
echo 1

}
function configure_networking_options(){
echo 1
}
function configure_the_compute_service_to_use_the_networking_service(){
echo 1
}
function finalize_installation(){
echo 1

}

function network_compute_node_main(){
    install_the_components
    configure_the_common_component
    configure_networking_options
    configure_the_compute_service_to_use_the_networking_service
    finalize_installation
}