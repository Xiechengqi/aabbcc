#!/usr/bin/env bash

#
# xiechengqi
# 2021/12/21
# get WindowPoST metric
#

metricPath='/data/metric'
if [ ! -d ${metricPath} ]
then
mkdir -p ${metricPath} || exit 1
fi

function main() {

ip="$(hostname -I | awk '{print $1}')"
windowPost_log_file_path=`ls -t /var/log/containers/window-post-miner-* | head -1`
[ ".${windowPost_log_file_path}" = "." ] && echo "Not found window post file" && exit 1

# 收集指标
# 最新一次 windowPoST 运行时间
windowPost_run_time=$(grep 'computing window post' ${windowPost_log_file_path} | tail -1 | awk -F 'elapsed' '{print $NF}' | awk -F '}' '{print $1}' | awk '{print $NF}')
[ ".${windowPost_run_time}" = "." ] && windowPost_run_time="0"
windowPost_run_timestamp_tmp=$(grep 'computing window post' ${windowPost_log_file_path} | tail -1 | awk -F '"log":"' '{print $NF}' | awk -F '\' '{print $1}')
if [ "${windowPost_run_timestamp_tmp}" = "" ]
then
windowPost_run_timestamp="0"
windowPost_run_date="0-0-0 00:00:00"
else
windowPost_run_timestamp=$(TZ=UTC-8 date -d ${windowPost_run_timestamp_tmp} +%s)
windowPost_run_date=$(TZ=UTC-8 date '+%Y-%m-%d %H:%M:%S' -d @${windowPost_run_timestamp})
fi

# 最新一次 windowPoST 运行失败
windowPost_fail_timestamp_tmp=$(grep 'running window post failed' ${windowPost_log_file_path} | tail -1 | awk -F '"log":"' '{print $NF}' | awk -F '\' '{print $1}')
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
windowPost_run_time{ip="${ip}", hostname="$(hostname)"} ${windowPost_run_time}
# HELP windowPost_run_timestamp get windowPost run timestamp
# TYPE windowPost_run_timestamp gauge
windowPost_run_timestamp{ip="${ip}", hostname="$(hostname)"} ${windowPost_run_timestamp}
# HELP windowPost_fail_timestamp get windowPost fail timestamp
# TYPE windowPost_fail_timestamp gauge
windowPost_fail_timestamp{ip="${ip}", hostname="$(hostname)"} ${windowPost_fail_timestamp}
EOF

mv ${metricPath}/.windowPost-metric ${metricPath}/windowPost-metric.prom

if [ -f ${metricPath}/windowPost_history-metric.prom ]
then

tail -1 ${metricPath}/windowPost_history-metric.prom | grep "${windowPost_run_date}" &> /dev/null
if [ "$?" != "0" ]
then
cp -f ${metricPath}/windowPost_history-metric.prom ${metricPath}/.windowPost_history-metric
cat >> ${metricPath}/.windowPost_history-metric << EOF
windowPost_history{ip="${ip}", hostname="$(hostname)", date="${windowPost_run_date}"} ${windowPost_run_time}
EOF
mv ${metricPath}/.windowPost_history-metric ${metricPath}/windowPost_history-metric.prom
fi

else

cat > ${metricPath}/.windowPost_history-metric << EOF
# HELP windowPost_history get windowPost history info
# TYPE windowPost_history gauge
windowPost_history{ip="${ip}", hostname="$(hostname)", date="${windowPost_run_date}"} ${windowPost_run_time}
EOF
mv ${metricPath}/.windowPost_history-metric ${metricPath}/windowPost_history-metric.prom

fi

}

main $@
