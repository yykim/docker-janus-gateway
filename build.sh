#!/usr/bin/env bash

version=`date +%Y%m%d`

echo "build version $version"
# docker rmi yykim/janus-gateway:$version
# docker build -t yykim/janus-gateway:$version .
docker rmi yykim/janus-gateway
docker build -t yykim/janus-gateway .


#/etc/security/limits.conf
#*               soft    nproc           64000
#*               hard    nproc           64000
#*               soft    nofile          64000
#*               hard    nofile          64000
#root            soft    nproc           64000
#root            hard    nproc           64000
#root            soft    nofile          64000
#root            hard    nofile          64000
