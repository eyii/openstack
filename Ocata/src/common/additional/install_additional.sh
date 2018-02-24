#!/usr/bin/env bash
#source ./../common_function.sh

prompt '8扩展服务https://docs.openstack.org/ocata/install-guide-rdo/additional-services.html';
:<<comment
    #https://docs.openstack.org/ocata/install-guide-rdo/launch-instance.html
    Bare Metal service (ironic)
    Container Infrastructure Management service (magnum)
    Database service (trove)
    DNS service (designate)
    Key Manager service (barbican)
    Messaging service (zaqar)
    Object Storage services (swift)
    Orchestration service (heat)
    Shared File Systems service (manila)
    Telemetry Alarming services (aodh)
    Telemetry Data Collection service (ceilometer)
comment


function install_additional(){
    echo 'dddd'
}
