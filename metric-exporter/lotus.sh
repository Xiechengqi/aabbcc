#!/usr/bin/env bash

#
# xiechengqi
# 2021/11/22
# get lotus metric
#

metricPath='/data/metric' && mkdir -p ${metricPath} || exit 1

function main() {
# 收集指标
ps axu | grep -v grep | grep fuse_dfs &> /dev/null
lotus_storage_health=$?

# log_metric_status ${lotus_storage_health} "lotus_storage_health"

# 构建 prometheus textfile
cat > ${metricPath}/.lotus << EOF
# HELP lotus_storage_health get lotus storage health
# TYPE lotus_storage_health gauge
lotus_storage_health{hostname="$(hostname)"} ${lotus_storage_health}
EOF

mv ${metricPath}/.${fileName} ${metricPath}/${fileName}.prom
}

main $@
