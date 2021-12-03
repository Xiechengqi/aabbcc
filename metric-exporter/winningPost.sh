#!/usr/bin/env bash

#
# xiechengqi
# 2021/12/03
# get winningPost metric
#

metricPath='/data/metric'
if [ ! -d ${metricPath} ]
then
mkdir -p ${metricPath} || exit 1
fi

function main() {
# 收集指标
winningPost_run_time=$(grep 'GenerateWinningPoSt took' /var/log/containers/winning-post-miner-32g-mainnet-poster*.log | tail -1 | awk -F 'took ' '{print $NF}' | awk -F 's' '{print $1}')
winningPost_run_timestamp_tmp=$(grep 'GenerateWinningPoSt took' /var/log/containers/winning-post-miner-32g-mainnet-poster*.log | tail -1 | awk -F 'time' '{print $NF}' | cut -c 4- | rev | cut -c 3- | rev)
if [ "${winningPost_run_timestamp_tmp}" = "" ]
then
winningPost_run_timestamp="0"
winningPost_run_date="0-0-0 00:00:00"
else
winningPost_run_timestamp=$(date -d ${winningPost_run_timestamp_tmp} +%s)
winningPost_run_date=$(date '+%Y-%m-%d %H:%M:%S' -d @${winningPost_run_timestamp})
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

if [ -f ${metricPath}/winningPost_history-metric.prom ]
then
cp -f ${metricPath}/winningPost_history-metric.prom ${metricPath}/.winningPost_history-metric
cat >> ${metricPath}/.winningPost_history-metric << EOF
winningPost_history{hostname="$(hostname)", date="${winningPost_run_date}"} ${winningPost_run_time}
EOF
else
cat > ${metricPath}/.winningPost_history-metric << EOF
# HELP winningPost_history get winningPost history info
# TYPE winningPost_history gauge
winningPost_history{hostname="$(hostname)", date="${winningPost_run_date}"} ${winningPost_run_time}
EOF
fi

mv ${metricPath}/.winningPost_history-metric ${metricPath}/winningPost_history-metric.prom

}

main $@
