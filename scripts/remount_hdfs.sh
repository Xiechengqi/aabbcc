#!/usr/bin/env bash

echo '=> cp -r /opt/hadoop-3.3.1 /opt/hadoop-3.3.1_bak' && su - fbg -c 'cp -r /opt/hadoop-3.3.1 /opt/hadoop-3.3.1_bak' || exit 1
echo '=> tar zxvf /home/fbg/native.tgz -C /' && su - fbg -c 'tar zxvf /home/fbg/native.tgz -C /' || exit 1
echo '=> cd /opt/hadoop-3.3.1/bin' && cd /opt/hadoop-3.3.1/bin
echo '=> ./humount.sh /mnt/rfs' && ./humount.sh /mnt/rfs
echo 'wait for 10s ...' && sleep 10
echo '=> ps aux | grep -v grep| grep fuse_dfs' && ps -ef | grep -v grep |grep fuse_dfs && exit 1
echo '=> ./hmount.sh /mnt/rfs' && ./hmount.sh /mnt/rfs
echo 'wait for 10s ...' && sleep 10
echo '=> ps aux | grep -v grep| grep fuse_dfs' && ps aux | grep -v grep| grep fuse_dfs
echo '=> ls /mnt/rfs/fil' && ls /mnt/rfs/fil
