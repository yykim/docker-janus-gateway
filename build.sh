#!/usr/bin/env bash

version=`date +%Y%m%d`

echo "build version $version"
docker rmi yykim/janus-gateway:$version
docker build -t yykim/janus-gateway:$version .
