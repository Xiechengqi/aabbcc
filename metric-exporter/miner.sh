#!/usr/bin/env bash

#
# xiechengqi
# 2022/01/14
# get miner metric
#

trap "_clean" EXIT

_clean() {
cd /tmp && rm -f $$_*
}

metricPath='/data/metric'
if [ ! -d ${metricPath} ]
then
mkdir -p ${metricPath} || exit 1
fi

function main() {

ip=`hostname -I | awk '{print $1}'`
hostName=`hostname`
nowHour=`date +%H`
nowMin=`date +%M`

# 收集指标
# sealPreCommit1Failed number metric
miner_p1_fail_num=$(grep -i 'sealPreCommit1Failed' /var/log/containers/seal-miner-*.log | grep 'acquire' | awk -F '{' '{print $NF}' | awk -F '}' '{print $1}' | awk '{print $NF}' | sort | uniq | wc -l)

## log metric
lotus_move_storage_sector_id=`grep 'MoveStorage done' /var/log/containers/seal-miner-*.log | grep -E '[0-9]+m[0-9]' | tail -1 | awk -F 'sector ID: ' '{print $NF}' | awk -F '.' '{print $1}'`
[ ".${lotus_move_storage_sector_id}" = "." ] && lotus_move_storage_sector_id="0"
lotus_move_storage_spend_time_tmp=`grep 'MoveStorage done' /var/log/containers/seal-miner-*.log | grep -E '[0-9]+m[0-9]' | tail -1 | awk -F 'elapse ' '{print $NF}' | awk -F '.' '{print $1}'`
[ ".${lotus_move_storage_spend_time_tmp}" = "." ] && lotus_move_storage_spend_time="0"
lotus_move_storage_spend_time_minute=`echo ${lotus_move_storage_spend_time_tmp} | awk -F 'm' '{print $1}'`
lotus_move_storage_spend_time_second=`echo ${lotus_move_storage_spend_time_tmp} | awk -F 'm' '{print $NF}'`
lotus_move_storage_spend_time=`echo "${lotus_move_storage_spend_time_minute}*60 + ${lotus_move_storage_spend_time_second}" | bc`

## check redis
lotus_redis_status="0"
grep 'dial tcp'  /var/log/containers/seal-miner-*.log | egrep -v '3456|3457' &> /dev/null && lotus_redis_status="1"

## check websocket
lotus_websocket_status="0"
grep 'websocket connection closed' /var/log/containers/seal-miner-*.log &> /dev/null && lotus_websocket_status="1"

# 构建 prometheus textfile
[ ".${lotus_move_storage_spend_time}" = "." ] && lotus_move_storage_spend_time="0"
cat > ${metricPath}/.miner-metric << EOF
# HELP miner_p1_fail_num get sealPreCommit1Failed number
# TYPE miner_p1_fail_num gauge
miner_p1_fail_num{ip="${ip}", hostname="${hostName}"} ${miner_p1_fail_num}
# HELP lotus_move_storage_spend_time get lotus move storage spend time
# TYPE lotus_move_storage_spend_time gauge
lotus_move_storage_spend_time{ip="${ip}", hostname="${hostName}", sector_id="${lotus_move_storage_sector_id}"} ${lotus_move_storage_spend_time}
# HELP lotus_redis_status get lotus redis status
# TYPE lotus_redis_status
lotus_redis_status{ip="${ip}", hostname="${hostName}"} ${lotus_redis_status}
# HELP lotus_websocket_status get lotus websocket status
# TYPE lotus_websocket_status
lotus_websocket_status{ip="${ip}", hostname="${hostName}"} ${lotus_websocket_status}
EOF

mv ${metricPath}/.miner-metric ${metricPath}/miner-metric.prom

if [ "$nowHour" = "16" ] && [ "$nowMin" = "55" ]
then

# seal miner container
containerName=`docker ps | grep seal-miner | grep -v pause | head -1 | awk '{print $NF}'`

# create prometheus textfile
cat > ${metricPath}/.expired_sector-metric << EOF
# HELP lotus_expired_sector get lotus expired sector
# TYPE lotus_expired_sector gauge
EOF

# collect p1 fail sector id from log
grep -i 'sealPreCommit1Failed' /var/log/containers/seal-miner-* | grep 'acquire' | awk -F '{' '{print $NF}' | awk -F '}' '{print $1}' | awk '{print $NF}' | sort | uniq > /tmp/$$_p1_fail_sector_id_list

for sectorId in `cat /tmp/$$_p1_fail_sector_id_list`
do

# check sector
# if sector in ~/.lotusminer/unsealed, skip this loop
docker exec ${containerName} ls ~/.lotusminer/unsealed | grep "${sectorId} " &> /dev/null && continue
# if sector status is proving, skip this loop
docker exec ${containerName} lotus-miner sectors status "${sectorId}" | grep -i 'status' | grep -i 'proving' &> /dev/null && continue
# if sector log does not contain finalize, skip this loop
! docker exec ${containerName} lotus-miner sectors status --log ${sectorId} | grep -i 'finalize' &> /dev/null && continue

expire_date=`docker exec ${containerName} lotus-miner sectors status --log ${sectorId} | grep -i 'finalize' | tail -1 | awk -F '+' '{print $1}' | awk -F '.' '{print $NF}'`
expired_timestamp=`date -d "${expire_date}" +%s`
now_timestamp=`date +%s`
expired_time=`echo "(${now_timestamp} - ${expired_timestamp}) / 3600" | bc`
cat >> ${metricPath}/.expired_sector-metric << EOF
lotus_expired_sector{ip="${ip}", hostname="${hostName}", expired_time="${expired_time}"} ${sectorId}
EOF

done

mv ${metricPath}/.expired_sector-metric ${metricPath}/expired_sector-metric.prom
fi

}

main $@
