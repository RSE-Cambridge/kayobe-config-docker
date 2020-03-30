#!/bin/sh

cd $(dirname $0)
build_date=$(date +%Y%m%d-%H%M%S)
jenkins_ver=jdk11
docker build -t jenkins-docker --build-arg "BUILD_DATE=$build_date" \
       --build-arg "JENKINS_VER=$jenkins_ver" .

