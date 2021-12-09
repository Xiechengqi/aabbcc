#!/usr/bin/env bash

#
# xiechengqi
# 2021/12/09
# get miner metric
#

metricPath='/data/metric'
if [ ! -d ${metricPath} ]
then
mkdir -p ${metricPath} || exit 1
fi

function main() {

ip=`hostname -I | awk '{print $1}'`

# 收集指标
# sealPreCommit1Failed number metric
miner_p1_fail_num=$(grep -i 'sealPreCommit1Failed' /var/log/containers/seal-miner-32g-mainnet-*.log | grep 'acquire' | awk -F '{' '{print $NF}' | awk -F '}' '{print $1}' | awk '{print $NF}' | sort | uniq | wc -l)

## log metric
lotus_move_storage_sector_id=`grep 'MoveStorage done' /var/log/containers/seal-miner-32g-mainnet-*.log | grep -E '[0-9]+m[0-9]' | tail -1 | awk -F 'sector ID: ' '{print $NF}' | awk -F '.' '{print $1}'`
[ ".${lotus_move_storage_sector_id}" = "." ] && lotus_move_storage_sector_id="0"
lotus_move_storage_spend_time_tmp=`grep 'MoveStorage done' /var/log/containers/seal-miner-32g-mainnet-*.log | grep -E '[0-9]+m[0-9]' | tail -1 | awk -F 'elapse ' '{print $NF}' | awk -F '.' '{print $1}'`
[ ".${lotus_move_storage_spend_time_tmp}" = "." ] && lotus_move_storage_spend_time="0"
lotus_move_storage_spend_time_minute=`echo ${lotus_move_storage_spend_time_tmp} | awk -F 'm' '{print $1}'`
lotus_move_storage_spend_time_second=`echo ${lotus_move_storage_spend_time_tmp} | awk -F 'm' '{print $NF}'`
lotus_move_storage_spend_time=`echo "${lotus_move_storage_spend_time_minute}*60 + ${lotus_move_storage_spend_time_second}" | bc`

# 构建 prometheus textfile
cat > ${metricPath}/.miner-metric << EOF
# HELP miner_p1_fail_num get sealPreCommit1Failed number
# TYPE miner_p1_fail_num gauge
miner_p1_fail_num{ip="${ip}", hostname="$(hostname)"} ${miner_p1_fail_num}
# HELP lotus_move_storage_sector_id get lotus move storage sector id 
# TYPE lotus_move_storage_sector_id gauge
lotus_move_storage_sector_id{ip="${ip}", hostname="$(hostname)"} ${lotus_move_storage_sector_id}
# HELP lotus_move_storage_spend_time get lotus move storage spend time
# TYPE lotus_move_storage_spend_time gauge
lotus_move_storage_spend_time{ip="${ip}", hostname="$(hostname)"} ${lotus_move_storage_spend_time}
EOF

mv ${metricPath}/.miner-metric ${metricPath}/miner-metric.prom
}

main $@
