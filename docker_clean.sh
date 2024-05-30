#!/bin/bash
for tag in $(sudo docker image ls | sed 1,4d | awk '{print $3}')
do
    sudo docker image rm -f $tag
done