#!/usr/bin/env bash

#
# xiechengqi
# 2021/11/22
# get winningPost metric
#

metricPath='/data/metric' && mkdir -p ${metricPath} || exit 1

function main() {
# 收集指标
winningPost_run_time=$(grep 'GenerateWinningPoSt took' /var/log/containers/winning-post-miner-32g-mainnet-poster*.log | tail -1 | awk -F 'took ' '{print $NF}' | awk -F 's' '{print $1}')

# 构建 prometheus textfile
cat > ${metricPath}/.winningPost-metric << EOF
# HELP winningPost_run_time get winningPost run time
# TYPE winningPost_run_time gauge
winningPost_run_time{hostname="$(hostname)"} ${winningPost_run_time}
EOF

mv ${metricPath}/.winningPost-metric ${metricPath}/winningPost-metric.prom
}

main $@
