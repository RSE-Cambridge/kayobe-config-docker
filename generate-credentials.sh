#!/bin/bash

set -euo pipefail

admin_basic_passwd=$(openssl rand -base64 32)
admin_basic_htpasswd=$(printf "admin:$(openssl passwd -apr1 $admin_basic_passwd )\n")
echo "Jenkins basic auth admin password:" 
echo "${admin_basic_passwd}"
echo "htpasswd line for admin user:"
echo "$admin_basic_htpasswd"