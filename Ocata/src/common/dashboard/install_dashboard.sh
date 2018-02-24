#!/usr/bin/env bash
if [ -f "../api/common_function.sh" ]; then
  source "../api/common_function.sh"
  else
  source "./api/common_function.sh"
fi

prompt "6 仪表盘（dashboard）";
:<<comment
https://docs.openstack.org/ocata/install-guide-rdo/horizon.html
Install and configure
    Install and configure components
    Finalize installation
Verify operation
Next steps
comment

function install_and_configure(){
yum -y install openstack-dashboard
local_settings="/etc/openstack-dashboard/local_settings";
remove_file {$local_settings,}

cat >> $local_settings <<EOF
import os

from django.utils.translation import ugettext_lazy as _


from openstack_dashboard.settings import HORIZON_CONFIG

DEBUG = False

WEBROOT = "/dashboard/"

ALLOWED_HOSTS = ["*"]


LOCAL_PATH = "/tmp"

SECRET_KEY="6808a0e42fac9873a441"
SESSION_ENGINE = 'django.contrib.sessions.backends.cache'
CACHES = {
    "default": {
           'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
          'LOCATION': "${CONTROLLER_HOST_NAME}:11211",
    },
}

EMAIL_BACKEND = "django.core.mail.backends.console.EmailBackend"

OPENSTACK_HOST = "${CONTROLLER_HOST_NAME}"
OPENSTACK_KEYSTONE_URL = "http://%s:5000/v3" % OPENSTACK_HOST
OPENSTACK_KEYSTONE_DEFAULT_DOMAIN = "Default"
OPENSTACK_KEYSTONE_DEFAULT_ROLE = "user"
OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = True
OPENSTACK_API_VERSIONS = {
 "identity": 3,
"image": 2,
"volume": 2, }

OPENSTACK_KEYSTONE_BACKEND = {
    "name": "native",
    "can_edit_user": True,
    "can_edit_group": True,
    "can_edit_project": True,
    "can_edit_domain": True,
    "can_edit_role": True,
}


OPENSTACK_HYPERVISOR_FEATURES = {
    "can_set_mount_point": False,
    "can_set_password": False,
    "requires_keypair": False,
    "enable_quotas": True
}

OPENSTACK_CINDER_FEATURES = {
    "enable_backup": False,
}

OPENSTACK_NEUTRON_NETWORK = {
  'enable_router': False,
    'enable_quotas': False,
    'enable_distributed_router': False,
    'enable_ha_router': False,
    'enable_lb': False,
    'enable_firewall': False,
    'enable_vpn': False,
    'enable_fip_topology_check': False,
}

OPENSTACK_HEAT_STACK = {
    "enable_user_pass": True,
}

IMAGE_CUSTOM_PROPERTY_TITLES = {
    "architecture": _("Architecture"),
    "kernel_id": _("Kernel ID"),
    "ramdisk_id": _("Ramdisk ID"),
    "image_state": _("Euca2ools state"),
    "project_id": _("Project ID"),
    "image_type": _("Image Type"),
}

IMAGE_RESERVED_CUSTOM_PROPERTIES = []


API_RESULT_LIMIT = 1000
API_RESULT_PAGE_SIZE = 20

SWIFT_FILE_TRANSFER_CHUNK_SIZE = 512 * 1024

INSTANCE_LOG_LENGTH = 35

DROPDOWN_MAX_ITEMS = 30

TIME_ZONE = "Asia/Shanghai"


POLICY_FILES_PATH = "/etc/openstack-dashboard"


LOGGING = {
    "version": 1,
    "disable_existing_loggers": False,
    "formatters": {
        "operation": {
            "format": "%(asctime)s %(message)s"
        },
    },
    "handlers": {
        "null": {
            "level": "DEBUG",
            "class": "logging.NullHandler",
        },
        "console": {
            # Set the level to "DEBUG" for verbose output logging.
            "level": "INFO",
            "class": "logging.StreamHandler",
        },
        "operation": {
            "level": "INFO",
            "class": "logging.StreamHandler",
            "formatter": "operation",
        },
    },
    "loggers": {
        "django.db.backends": {
            "handlers": ["null"],
            "propagate": False,
        },
        "requests": {
            "handlers": ["null"],
            "propagate": False,
        },
        "horizon": {
            "handlers": ["console"],
            "level": "DEBUG",
            "propagate": False,
        },
        "horizon.operation_log": {
            "handlers": ["operation"],
            "level": "INFO",
            "propagate": False,
        },
        "openstack_dashboard": {
            "handlers": ["console"],
            "level": "DEBUG",
            "propagate": False,
        },
        "novaclient": {
            "handlers": ["console"],
            "level": "DEBUG",
            "propagate": False,
        },
        "cinderclient": {
            "handlers": ["console"],
            "level": "DEBUG",
            "propagate": False,
        },
        "keystoneclient": {
            "handlers": ["console"],
            "level": "DEBUG",
            "propagate": False,
        },
        "glanceclient": {
            "handlers": ["console"],
            "level": "DEBUG",
            "propagate": False,
        },
        "neutronclient": {
            "handlers": ["console"],
            "level": "DEBUG",
            "propagate": False,
        },
        "heatclient": {
            "handlers": ["console"],
            "level": "DEBUG",
            "propagate": False,
        },
        "swiftclient": {
            "handlers": ["console"],
            "level": "DEBUG",
            "propagate": False,
        },
        "openstack_auth": {
            "handlers": ["console"],
            "level": "DEBUG",
            "propagate": False,
        },
        "nose.plugins.manager": {
            "handlers": ["console"],
            "level": "DEBUG",
            "propagate": False,
        },
        "django": {
            "handlers": ["console"],
            "level": "DEBUG",
            "propagate": False,
        },
        "iso8601": {
            "handlers": ["null"],
            "propagate": False,
        },
        "scss": {
            "handlers": ["null"],
            "propagate": False,
        },
    },
}

SECURITY_GROUP_RULES = {
    "all_tcp": {
        "name": _("All TCP"),
        "ip_protocol": "tcp",
        "from_port": "1",
        "to_port": "65535",
    },
    "all_udp": {
        "name": _("All UDP"),
        "ip_protocol": "udp",
        "from_port": "1",
        "to_port": "65535",
    },
    "all_icmp": {
        "name": _("All ICMP"),
        "ip_protocol": "icmp",
        "from_port": "-1",
        "to_port": "-1",
    },
    "ssh": {
        "name": "SSH",
        "ip_protocol": "tcp",
        "from_port": "22",
        "to_port": "22",
    },
    "smtp": {
        "name": "SMTP",
        "ip_protocol": "tcp",
        "from_port": "25",
        "to_port": "25",
    },
    "dns": {
        "name": "DNS",
        "ip_protocol": "tcp",
        "from_port": "53",
        "to_port": "53",
    },
    "http": {
        "name": "HTTP",
        "ip_protocol": "tcp",
        "from_port": "80",
        "to_port": "80",
    },
    "pop3": {
        "name": "POP3",
        "ip_protocol": "tcp",
        "from_port": "110",
        "to_port": "110",
    },
    "imap": {
        "name": "IMAP",
        "ip_protocol": "tcp",
        "from_port": "143",
        "to_port": "143",
    },
    "ldap": {
        "name": "LDAP",
        "ip_protocol": "tcp",
        "from_port": "389",
        "to_port": "389",
    },
    "https": {
        "name": "HTTPS",
        "ip_protocol": "tcp",
        "from_port": "443",
        "to_port": "443",
    },
    "smtps": {
        "name": "SMTPS",
        "ip_protocol": "tcp",
        "from_port": "465",
        "to_port": "465",
    },
    "imaps": {
        "name": "IMAPS",
        "ip_protocol": "tcp",
        "from_port": "993",
        "to_port": "993",
    },
    "pop3s": {
        "name": "POP3S",
        "ip_protocol": "tcp",
        "from_port": "995",
        "to_port": "995",
    },
    "ms_sql": {
        "name": "MS SQL",
        "ip_protocol": "tcp",
        "from_port": "1433",
        "to_port": "1433",
    },
    "mysql": {
        "name": "MYSQL",
        "ip_protocol": "tcp",
        "from_port": "3306",
        "to_port": "3306",
    },
    "rdp": {
        "name": "RDP",
        "ip_protocol": "tcp",
        "from_port": "3389",
        "to_port": "3389",
    },
}

REST_API_REQUIRED_SETTINGS = ["OPENSTACK_HYPERVISOR_FEATURES",
                              "LAUNCH_INSTANCE_DEFAULTS",
                              "OPENSTACK_IMAGE_FORMATS",
                              "OPENSTACK_KEYSTONE_DEFAULT_DOMAIN"]


ALLOWED_PRIVATE_SUBNET_CIDR = {"ipv4": [], "ipv6": []}
EOF




}
function finalize_installation(){
systemctl restart httpd.service memcached.service
}


function verify_operation(){

prompt "http://controller/dashboard"

#Authenticate using admin or demo user and default domain credentials.
}
function next_steps(){
echo 'next_steps'
}


function main_dashboard(){
install_and_configure
finalize_installation
verify_operation
next_steps
}

