#!/usr/bin/env bash

#
# xiechengqi
# 2021/11/22
# get windowPost metric
#

metricPath='/data/metric' && mkdir -p ${metricPath} || exit 1

function main() {
# 收集指标
windowPost_run_time=$(grep 'computing window post' /var/log/containers/window-post-miner-32g-mainnet-poster*.log | tail -1 | awk -F 'elapsed' '{print $NF}' | awk -F '}' '{print $1}' | awk '{print $NF}')

# 构建 prometheus textfile
cat > ${metricPath}/.windowPost-metric << EOF
# HELP windowPost_run_time get windowPost run time
# TYPE windowPost_run_time gauge
windowPost_run_time{hostname="$(hostname)"} ${windowPost_run_time}
EOF

mv ${metricPath}/.windowPost-metric ${metricPath}/windowPost-metric.prom
}

main $@
