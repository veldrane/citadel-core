#!/bin/bash

REGISTRY="registry.class.syscallx86.com"

for a in `cat images.lst`; do 
	export DIR=`echo $a | grep -E "\/.+\/" | awk -F \/ '{print $(NF-1)}'` 
	export TAG=`echo $a | awk -F\: '{print $2}'`; export FILE=`echo $a |  grep -E "\/.+\/" | awk -F \/ '{print $(NF)}' | awk -F\: '{print $1}'`
	[[ $DIR != "" ]] && mkdir -p $DIR && cd $DIR
	podman pull $a 
	[[ $DIR != "" ]] && export TAG=`echo $a | awk -F\: '{print $2}'`; export FILE=`echo $a |  grep -E "\/.+\/" | awk -F \/ '{print $(NF)}' | awk -F\: '{print $1}'`
	[[ $DIR == "" ]] && export TAG=`echo $a | awk -F\: '{print $2}'`; export FILE=`echo $a | awk -F \/ '{print $(NF)}' | awk -F\: '{print $1}'`
	podman save $a -o $FILE.tar--$TAG; cd /data/images ; 
done

