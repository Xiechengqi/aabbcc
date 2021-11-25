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
winningPost_run_timestamp_tmp=$(grep 'GenerateWinningPoSt took' /var/log/containers/winning-post-miner-32g-mainnet-poster*.log | tail -1 | awk -F 'time' '{print $NF}' | cut -c 4- | rev | cut -c 3- | rev)
if [ "${winningPost_run_timestamp_tmp}" = "" ]
then
winningPost_run_timestamp="0"
else
winningPost_run_timestamp=$(date -d ${winningPost_run_timestamp_tmp} +%s)
fi

# 构建 prometheus textfile
cat > ${metricPath}/.winningPost-metric << EOF
# HELP winningPost_run_time get winningPost run time
# TYPE winningPost_run_time gauge
winningPost_run_time{hostname="$(hostname)"} ${winningPost_run_time}
# HELP winningPost_run_timestamp get winningPost run timestamp
# TYPE winningPost_run_timestamp gauge
winningPost_run_timestamp{hostname="$(hostname)"} ${winningPost_run_timestamp}
EOF

mv ${metricPath}/.winningPost-metric ${metricPath}/winningPost-metric.prom
}

main $@
