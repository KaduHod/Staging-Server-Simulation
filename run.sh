#!/bin/bash
ssh-keygen -f "/home/carlos/.ssh/known_hosts" -R "172.17.0.2"
docker run -it -p 8080:8080 --name homol-ubuntu kaduhod/ubuntu
sshpass -p "123456" ssh-copy-id deployer@$172.17.0.2
