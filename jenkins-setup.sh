#!/bin/bash

set -euo pipefail

sudo ./jenkins-docker/build.sh

sudo docker tag jenkins-docker:latest 10.200.0.1:4000/jenkins-docker:latest

sudo docker push 10.200.0.1:4000/jenkins-docker:latest

sudo mkdir -p /etc/nginx-proxy/htpasswd
sudo mkdir -p /etc/nginx-proxy/certs

export jenkins_virtual_host="10.60.150.1"

export admin_basic_passwd=$(openssl rand -base64 32)
export admin_basic_htpasswd=$(printf "admin:$(openssl passwd -apr1 $admin_basic_passwd )\n")
export nginx_htpasswd_file="/etc/nginx-proxy/htpasswd/${jenkins_virtual_host}"
export password_hint="Jenkins basic auth admin password:
${admin_basic_passwd}"
sudo -E sh -c 'test -f "${nginx_htpasswd_file}" || (echo "${admin_basic_htpasswd}" > "${nginx_htpasswd_file}" && echo "$password_hint")'

# Ensure non-world readable - 101 is the uid of the nginx user in the container
sudo -E sh -c 'chown 101:101 "${nginx_htpasswd_file}" && chmod 660 "${nginx_htpasswd_file}"'

echo "nginx_proxy container id:"
sudo docker run --name=nginx_proxy \
     --volume="/var/run/docker.sock:/tmp/docker.sock:ro" \
     --volume="/etc/nginx-proxy/htpasswd:/etc/nginx/htpasswd:ro" \
     --volume="/etc/nginx-proxy/certs:/etc/nginx/certs:rw" \
     --volume="nginx_vhost:/etc/nginx/vhost.d:rw" \
     -p 0.0.0.0:80:80 \
     -p 0.0.0.0:443:443 \
     --restart=always \
     --detach=true \
     jwilder/nginx-proxy:latest

sudo mkdir -p /var/jenkins-home/jenkins-config
sudo cp -r jenkins-config/ /var/jenkins-home/

echo "jenkins container id:"
sudo docker run --name=jenkins \
     --env="VIRTUAL_PORT=8080" \
     --env="VIRTUAL_HOST=${jenkins_virtual_host}" \
     --volume="/var/jenkins-home:/var/jenkins-home:rw" \
     --volume="/var/run/docker.sock:/var/run/docker.sock:ro" \
     -p 0.0.0.0:18080:8080 \
     -p 0.0.0.0:50000:50000 \
     --restart=always \
     --detach=true \
     10.200.0.1:4000/jenkins-docker:latest
