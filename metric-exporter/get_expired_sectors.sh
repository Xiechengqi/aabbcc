#!/usr/bin/env bash

#
# xiechengqi
# 2021/12/11
# get expired sectors
#

metricPath='/data/metric'
if [ ! -d ${metricPath} ]
then
mkdir -p ${metricPath} || exit 1
fi

function main() {

ip=`hostname -I | awk '{print $1}'`
hostName=`hostname`

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
! docker exec ${containerName} ls ~/.lotusminer/unsealed | grep "${sectorId} " &> /dev/null && docker exec ${containerName} lotus-miner sectors status --log ${sectorId} | grep -i 'finalize' &> /dev/null
if [ "$?" = "0" ]
then
expire_date=`docker exec ${containerName} lotus-miner sectors status --log ${sectorId} | grep -i 'finalize' | tail -1 | awk -F '+' '{print $1}' | awk -F '.' '{print $NF}'`
expired_timestamp=`date -d "${expire_date}" +%s`
now_timestamp=`date +%s`
expired_time=`echo "(${now_timestamp} - ${expired_timestamp}) / 3600" | bc`
cat >> ${metricPath}/.expired_sector-metric << EOF
lotus_expired_sector{ip="${ip}", hostname="${hostName}", expired_time="${expired_time}"} ${sectorId}
EOF
fi
done

mv ${metricPath}/.expired_sector-metric ${metricPath}/expired_sector-metric.prom

}

main $@
