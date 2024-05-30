#!/bin/bash

clean(){
    for tag in $(sudo docker image ls | sed 1,4d | awk '{print $3}')
    do
        sudo docker image rm -f $tag
    done
}


while true; do
    read -p "Do you wish to clean up docker images [Yy/Nn]? " yn
    case $yn in
        [Yy]* ) clean;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

