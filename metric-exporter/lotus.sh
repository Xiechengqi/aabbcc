#!/usr/bin/env bash

#
# xiechengqi
# 2021/12/09
# get lotus metric
#

metricPath='/data/metric'
if [ ! -d ${metricPath} ]
then
mkdir -p ${metricPath} || exit 1
fi

function main() {

ip=$(hostname -I | awk '{print $1}')

# collect metric
## check fuse process status, aliyun -> fuse_dfs; qiniu -> fcfs.sh
ps axu | grep -v grep | grep fuse_dfs &> /dev/null || ps aux | grep -v grep | grep fcfs.sh &> /dev/null
lotus_storage_health=$?

# create prometheus textfile
cat > ${metricPath}/.lotus-metric << EOF
# HELP lotus_storage_health get lotus storage health
# TYPE lotus_storage_health gauge
lotus_storage_health{ip="${ip}", hostname="$(hostname)"} ${lotus_storage_health}
EOF

mv ${metricPath}/.lotus-metric ${metricPath}/lotus-metric.prom
}

main $@
