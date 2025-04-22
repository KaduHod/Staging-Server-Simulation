#!/bin/bash
ssh-keygen -f "/home/carlos/.ssh/known_hosts" -R "172.17.0.2"
docker run -it --name homol-ubuntu kaduhod/ubuntu
