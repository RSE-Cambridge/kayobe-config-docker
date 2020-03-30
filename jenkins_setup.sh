#!/bin/bash

set -euo pipefail

sudo ./jenkins-docker/build.sh

sudo docker tag jenkins-docker:latest 192.168.33.5:4000/jenkins-docker:latest

sudo docker push 192.168.33.5:4000/jenkins-docker:latest

sudo mkdir -p /etc/nginx-proxy/htpasswd
sudo mkdir -p /etc/nginx-proxy/certs

admin_basic_passwd=$(openssl rand -base64 32)
admin_basic_htpasswd=$(printf "admin:$(openssl passwd -apr1 $admin_basic_passwd )\n")
sudo sh -c 'echo "${admin_basic_htpasswd}" > /etc/nginx-proxy/htpasswd/jenkins.htpasswd'

echo "Jenkins basic auth admin password:"
echo "${admin_basic_passwd}"
echo ""

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

sudo mkdir -p /var/jenkins_home/jenkins_config
sudo cp -r jenkins_config/ /var/jenkins_home/

echo "jenkins container id:"
sudo docker run --name=jenkins \
     --env="VIRTUAL_PORT=8080" \
     --env="VIRTUAL_HOST=192.168.33.5" \
     --volume="/var/jenkins_home:/var/jenkins_home:rw" \
     --volume="/var/run/docker.sock:/var/run/docker.sock:ro" \
     -p 0.0.0.0:18080:8080 \
     -p 0.0.0.0:50000:50000 \
     --restart=always \
     --detach=true \
     192.168.33.5:4000/jenkins-docker:latest
