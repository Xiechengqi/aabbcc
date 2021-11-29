#!/usr/bin/env bash

#
# xiechengqi
# 2021/11/29
# get miner metric
#

metricPath='/data/metric'
if [ ! -d ${metricPath} ]
then
mkdir -p ${metricPath} || exit 1
fi

function main() {
# 收集指标
# P1 失败数量
miner_p1_fail_num=$(grep -i 'sealPreCommit1Failed' /var/log/containers/seal-miner-32g-mainnet-* | grep acquire | awk -F '{' '{print $NF}' | awk -F '}' '{print $1}' | awk '{print $NF}' | sort | uniq | wc -l)

# 构建 prometheus textfile
cat > ${metricPath}/.miner-metric << EOF
# HELP miner_p1_fail_num get sealPreCommit1Failed number
# TYPE miner_p1_fail_num gauge
miner_p1_fail_num{hostname="$(hostname)"} ${miner_p1_fail_num}
EOF

mv ${metricPath}/.miner-metric ${metricPath}/miner-metric.prom
}

main $@
