#!/usr/bin/env bash

#
# xiechengqi
# 2021/11/22
# get lotus metric
#

metricPath='/data/metric'
if [ ! -d ${metricPath} ]
then
mkdir -p ${metricPath} || exit 1
fi

function main() {
# 收集指标
ps axu | grep -v grep | grep fuse_dfs &> /dev/null
lotus_storage_health=$?

# 构建 prometheus textfile
cat > ${metricPath}/.lotus-metric << EOF
# HELP lotus_storage_health get lotus storage health
# TYPE lotus_storage_health gauge
lotus_storage_health{hostname="$(hostname)"} ${lotus_storage_health}
EOF

mv ${metricPath}/.lotus-metric ${metricPath}/lotus-metric.prom
}

main $@
