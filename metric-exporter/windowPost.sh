#!/usr/bin/env bash

#
# xiechengqi
# 2021/11/22
# get WindowPoST metric
#

metricPath='/data/metric' && mkdir -p ${metricPath} || exit 1

function main() {
# 收集指标
# 最新一次 windowPoST 运行时间
windowPost_run_time=$(grep 'computing window post' /var/log/containers/window-post-miner-32g-mainnet-poster*.log | tail -1 | awk -F 'elapsed' '{print $NF}' | awk -F '}' '{print $1}' | awk '{print $NF}')
windowPost_run_timestamp_tmp=$(grep 'computing window post' /var/log/containers/window-post-miner-32g-mainnet-poster*.log | tail -1 | awk -F 'u' '{print $1}' | cut -c 9- | rev | cut -c 2- | rev)
if [ "${windowPost_run_timestamp_tmp}" = "" ]
then
windowPost_run_timestamp="0"
else
windowPost_run_timestamp=$(date -d ${windowPost_run_timestamp_tmp} +%s)
fi

# 最新一次 windowPoST 运行失败
windowPost_fail_timestamp_tmp=$(grep 'running window post failed' /var/log/containers/window-post-miner-32g-mainnet-poster*.log | tail -1 | awk -F '"log":"' '{print $NF}' | awk -F '\' '{print $1}')
if [ "${windowPost_fail_timestamp_tmp}" = "" ]
then
windowPost_fail_timestamp="0"
else
windowPost_fail_timestamp=$(date -d ${windowPost_fail_timestamp_tmp} +%s)
fi

# 构建 prometheus textfile
cat > ${metricPath}/.windowPost-metric << EOF
# HELP windowPost_run_time get windowPost run time
# TYPE windowPost_run_time gauge
windowPost_run_time{hostname="$(hostname)"} ${windowPost_run_time}
# HELP windowPost_run_timestamp get windowPost run timestamp
# TYPE windowPost_run_timestamp gauge
windowPost_run_timestamp{hostname="$(hostname)"} ${windowPost_run_timestamp}
# HELP windowPost_fail_timestamp get windowPost fail timestamp
# TYPE windowPost_fail_timestamp gauge
windowPost_fail_timestamp{hostname="$(hostname)"} ${windowPost_fail_timestamp}
EOF

mv ${metricPath}/.windowPost-metric ${metricPath}/windowPost-metric.prom
}

main $@
