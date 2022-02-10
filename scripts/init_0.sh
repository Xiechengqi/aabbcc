#!/usr/bin/env bash

#
# 2022/02/10
# xiechengqi
# init os
#

source /etc/profile
BASEURL="https://gitee.com/Xiechengqi/scripts/raw/master"
source <(curl -SsL $BASEURL/tool/common.sh)

# EXEC "useradd -m -s /bin/bash reaper"
# EXEC "echo 'reaper:Root1234@' | sudo chpasswd"
# EXEC "mv /etc/apt/sources.list /etc/apt/sources.list.bak"
# EXEC "curl -SsL https://raw.githubusercontent.com/Xiechengqi/aabbcc/master/scripts/sources.list -o /etc/apt/sources.list"
# EXEC "cd / && rm -rf tmp"
# EXEC "mkdir /tmp"
# EXEC "chmod 777 /tmp"

suffixIp=$(hostname -I | awk '{print $1}' | awk -F '.' '{print $NF}')
hostName="miner"$(echo "${suffixIp} + 100" | bc)
EXEC "hostnamectl set-hostname ${hostName} && hostnamectl --pretty && hostnamectl --static && hostnamectl --transient"
