#!/bin/bash 

# change docker subnet
source /run/flannel/subnet.env
sed -i "s|ExecStart=.*|ExecStart=\/usr\/bin\/dockerd -H tcp:\/\/127.0.0.1:4243 -H unix:\/\/\/var\/run\/docker.sock --bip=${FLANNEL_SUBNET} --mtu=${FLANNEL_MTU} \$DOCKER_OPTS|g" /lib/systemd/system/docker.service

# remove docker0
rc=0
ip link show docker0 >/dev/null 2>&1 || rc="0"
if [[ "" -eq "0" ]]; then
    ip link set dev docker0 down
    ip link delete docker0
fi

systemctl daemon-reload

# restart docker if docker already exist
DOCKERNUM=$(ps -ef | grep "dockerd" | grep -v "grep" | wc -l)
if [[ "$DOCKERNUM" -eq "1" ]]; then
    systemctl restart docker
fi
