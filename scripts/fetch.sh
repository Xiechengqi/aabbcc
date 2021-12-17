#!/usr/bin/env bash

#
# 2021/12/16
# xiechengqi
# check sealed cache mnt sectors
#

cd /root/.lotusminer/sealed
for sealName in `ls | grep s-t01479781`
do
[ ".$sealName" = "." ] && break
if ls /mnt/sealed/mainnet/storage/f01479781/1/sealed/${sealName} &> /dev/null
then
sectorId=`echo $sealName | awk -F '-' '{print $NF}'`
lotus-miner sectors status ${sectorId} | grep -i status | grep -i proving &> /dev/null && continue
echo "check /root/.lotusminer/sealed/$sealName ... fail"
fi
done

cd /root/.lotusminer/cache
for sealName in `ls | grep s-t01479781`
do
[ ".$sealName" = "." ] && break
if ls /mnt/sealed/mainnet/storage/f01479781/1/cache/${sealName} &> /dev/null
then
sectorId=`echo $sealName | awk -F '-' '{print $NF}'`
lotus-miner sectors status ${sectorId} | grep -i status | grep -i proving &> /dev/null && continue
echo "check /root/.lotusminer/cache/$sealName ... fail"
fi
done
