#!/usr/bin/env bash

#
# xiechengqi
# 2021/12/03
# get WindowPoST metric
#

metricPath='/data/metric'
if [ ! -d ${metricPath} ]
then
mkdir -p ${metricPath} || exit 1
fi

function main() {
# 收集指标
# 最新一次 windowPoST 运行时间
windowPost_run_time=$(grep 'computing window post' /var/log/containers/window-post-miner-32g-mainnet-poster*.log | tail -1 | awk -F 'elapsed' '{print $NF}' | awk -F '}' '{print $1}' | awk '{print $NF}')
windowPost_run_timestamp_tmp=$(grep 'computing window post' /var/log/containers/window-post-miner-32g-mainnet-poster*.log | tail -1 | awk -F '"log":"' '{print $NF}' | awk -F '\' '{print $1}')
if [ "${windowPost_run_timestamp_tmp}" = "" ]
then
windowPost_run_timestamp="0"
winningPost_run_date="0-0-0 00:00:00"
else
windowPost_run_timestamp=$(date -d ${windowPost_run_timestamp_tmp} +%s)
windowPost_run_date=$(date '+%Y-%m-%d %H:%M:%S' -d @${winningPost_run_timestamp})
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

if [ -f ${metricPath}/windowPost_history-metric.prom ]
then

tail -1 ${metricPath}/windowPost_history-metric.prom | grep "${windowPost_run_date}" &> /dev/null
if [ "$?" != "0" ]
then
cp -f ${metricPath}/windowPost_history-metric.prom ${metricPath}/.windowPost_history-metric
cat >> ${metricPath}/.windowPost_history-metric << EOF
windowPost_history{hostname="$(hostname)", date="${windowPost_run_date}"} ${windowPost_run_time}
EOF
fi

else

cat > ${metricPath}/.windowPost_history-metric << EOF
# HELP windowPost_history get windowPost history info
# TYPE windowPost_history gauge
windowPost_history{hostname="$(hostname)", date="${windowPost_run_date}"} ${windowPost_run_time}
EOF

fi

mv ${metricPath}/.windowPost_history-metric ${metricPath}/windowPost_history-metric.prom

}

main $@
