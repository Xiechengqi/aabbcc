#!/usr/bin/env bash

#
# xiechengqi
# 2021/12/11
# get miner metric
#

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
miner_p1_fail_num{ip="${ip}", hostname="${hostName}"} ${miner_p1_fail_num}
# HELP lotus_move_storage_spend_time get lotus move storage spend time
# TYPE lotus_move_storage_spend_time gauge
lotus_move_storage_spend_time{ip="${ip}", hostname="${hostName}", sector_id="${lotus_move_storage_sector_id}"} ${lotus_move_storage_spend_time}
EOF

mv ${metricPath}/.miner-metric ${metricPath}/miner-metric.prom

if [ "$nowHour" = "14" ] && [ "$nowMin" = "15" ]
then

# seal miner container
containerName=`docker ps | grep seal-miner | grep -v pause | head -1 | awk '{print $NF}'`

# create prometheus textfile
cat > ${metricPath}/.expired_sector-metric << EOF
# HELP lotus_expired_sector get lotus expired sector
# TYPE lotus_expired_sector gauge
EOF

# collect p1 fail sector id from log
grep -i 'sealPreCommit1Failed' /var/log/containers/seal-miner-32g-mainnet-* | grep 'acquire' | awk -F '{' '{print $NF}' | awk -F '}' '{print $1}' | awk '{print $NF}' | sort | uniq > /tmp/$$_p1_fail_sector_id_list

# check sector, if in ~/.lotusminer/unsealed or no finalize in log, skip it
for sectorId in `cat /tmp/$$_p1_fail_sector_id_list`
do
! docker exec -it ${containerName} ls ~/.lotusminer/unsealed | grep "${sectorId} " &> /dev/null && docker exec -it ${containerName} lotus-miner sectors status --log ${sectorId} | grep -i 'finalize' &> /dev/null
if [ "$?" = "0" ]
then
expire_date=`docker exec -it ${containerName} lotus-miner sectors status --log ${sectorId} | grep -i 'finalize' | tail -1 | awk -F '+' '{print $1}' | awk -F '.' '{print $NF}'`
expired_timestamp=`date -d "${expire_date}" +%s`
now_timestamp=`date +%s`
expired_time=`echo "(${now_timestamp} - ${expired_timestamp}) / 3600" | bc`
cat >> ${metricPath}/.expired_sector-metric << EOF
lotus_expired_sector{ip="${ip}", hostname="${hostName}", expired_time="${expired_time}"} ${sectorId}
EOF
fi
done

mv ${metricPath}/.expired_sector-metric ${metricPath}/expired_sector-metric.prom
fi

}

main $@
