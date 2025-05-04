#!/bin/bash
docker run --privileged -it -p 8080:8080 -p 3000:3000 -p 3001:3001 -p 3002:3002 -p 3003:3003 -p 3004:3004 -p 3005:3005 -p 3006:3006 --name homol-ubuntu kaduhod/ubuntu
ssh-keygen -f "/home/carlos/.ssh/known_hosts" -R "172.17.0.2"
sshpass -p "123456" ssh-copy-id deployer@172.17.0.2
