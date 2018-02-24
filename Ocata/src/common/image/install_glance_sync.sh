#!/usr/bin/bash
su -s /bin/sh -c "glance-manage db_sync" glance
for svc in 'openstack-glance-api openstack-glance-registry '; do install_start_service ${svc} ; done