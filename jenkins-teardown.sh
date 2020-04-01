#!/bin/bash

set -eux

sudo docker stop nginx_proxy && sudo docker rm nginx_proxy
sudo docker stop jenkins && sudo docker rm jenkins
sudo docker stop letsencrypt_nginx && sudo docker rm letsencrypt_nginx
sudo rm -rf /var/jenkins_home/
