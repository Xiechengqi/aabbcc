#!/usr/bin/env bash

#
# 2021/12/29
# xiechengqi
# get sector AddPiece and  WaitDeals info
#

trap "_clean" EXIT

_clean() {
cd /tmp/ && rm -f $$_*
}


main() {
[ `docker ps | grep -v 'pause' | grep 'seal-miner' | wc -l` -gt "1" ]  && exit 1
containerName=`docker ps | grep -v 'pause' | grep 'seal-miner' | awk '{print $NF}'`
[ ".${containerName}" = "." ] && exit 1
docker exec -it ${containerName} which lotus-miner &> /dev/null || exit 1
docker exec -it ${containerName} lotus-miner sectors list --states=AddPiece | grep AddPiece > /tmp/$$_states_AddPiece
cat > /data/metric/.miner_normal_addpiece_metric << EOF
# HELP miner_sector_addpiece_spend_time get miner sector addpiece spend time
# TYPE miner_sector_addpiece_spend_time gauge
EOF

docker exec -it ${containerName} lotus-miner sealing jobs | grep AP > /tmp/$$_jobs_AddPiece
cat > /data/metric/.miner_hang_addpiece_metric << EOF
# HELP miner_sector_hang_addpiece get miner sector hang addpiece info
# TYPE miner_sector_hang_addpiece gauge
EOF

while read line
do

sector_id=`cat /tmp/$$_states_AddPiece | grep AddPiece | awk '{print $1}'`
if ! cat /tmp/$$_jobs_AddPiece | grep ${sector_id} &> /dev/null
then
cat >> /data/metric/.miner_hang_addpiece_metric << EOF
miner_sector_hang_addpiece{sector_id="${sector_id}"} 1
EOF
continue
fi

miner_sector_addpiece_spend_time_tmp=`cat /tmp/$$_jobs_AddPiece | grep ${sector_id} | awk '{print $NF}'`
echo ${miner_sector_addpiece_spend_time_tmp} | grep 'h' &> /dev/null && hours=`echo ${miner_sector_addpiece_spend_time_tmp} | awk -F 'h' '{print $1}'` && miner_sector_addpiece_spend_time_tmp=`echo ${miner_sector_addpiece_spend_time_tmp} | awk -F 'h' '{print $NF}'`
echo ${miner_sector_addpiece_spend_time_tmp} | grep 'm' &> /dev/null && minutes=`echo ${miner_sector_addpiece_spend_time_tmp} | awk -F 'm' '{print $1}'`
[ ".${hours}" = "." ] && hours="0"
[ ".${minutes}" = "." ] && minutes="0"
miner_sector_addpiece_spend_time=`echo "60 * ${hours} + ${minutes}" | bc`
cat >> /data/metric/.miner_normal_addpiece_metric << EOF
miner_sector_addpiece_spend_time{sector_id="${sector_id}"} ${miner_sector_addpiece_spend_time}
EOF

done < /tmp/$$_states_AddPiece

docker exec -it ${containerName} lotus-miner sectors list --states=WaitDeals > /tmp/$$_WaitDeals
cat > /data/metric/.miner_waitdeals_metric << EOF
# HELP miner_sector_waitdeals_spend_time get miner sector waitdeals spend time
# TYPE miner_sector_waitdeals_spend_time gauge
EOF

[ `cat /tmp/$$_WaitDeals | grep WaitDeals | wc -l` != "0" ] && while read line
do
sector_id=`cat /tmp/$$_WaitDeals | grep WaitDeals | awk '{print $1}'`
cat >> /data/metric/.miner_waitdeals_metric << EOF
miner_sector_waitdeals{sector_id="${sector_id}"} 1
EOF
done < /tmp/$$_WaitDeals

mv /data/metric/.miner_normal_addpiece_metric /data/metric/miner_normal_addpiece_metric.prom
mv /data/metric/.miner_hang_addpiece_metric /data/metric/miner_hang_addpiece_metric.prom
mv /data/metric/.miner_waitdeals_metric /data/metric/miner_waitdeals_metric.prom

}

main $@
