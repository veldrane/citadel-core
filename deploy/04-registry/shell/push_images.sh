#!/bin/bash

export REGISTRY="registry.class.syscallx86.com"

export TAG=$(echo $1 | awk -F\-\- '{print $2}')
export IMAGE=$(echo $1 | awk -F\.tar '{print $1}')
export DIRPATH=$(echo $1 | awk -F\.tar '{print $1}' | awk -F\. '{print $2}')

skopeo copy tarball:$1 docker://$REGISTRY$DIRPATH:$TAG --dest-tls-verify=false
