#!/bin/bash

set -eux

sudo docker stop nginx_proxy && sudo docker rm nginx_proxy
sudo docker stop jenkins && sudo docker rm jenkins
sudo rm -rf /var/jenkins-home/
