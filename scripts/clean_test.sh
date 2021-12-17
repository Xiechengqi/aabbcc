#!/usr/bin/env bash

#
# 2021/12/16
# xiechengqi
# check sealed cache mnt sectors
#

cd /root/.lotusminer/sealed || exit 1
for sealName in `ls | grep s-t01479781`
do
[ ".$sealName" = "." ] && break
if ls /mnt/sealed/mainnet/storage/f01479781/1/sealed/${sealName} &> /dev/null
then
sectorId=`echo $sealName | awk -F '-' '{print $NF}'`
[ ".${sectorId}" = "." ] && continue
[ "${sectorId}" -gt "778200" ] && continue
! lotus-miner sector status ${sectorId} | grep -i status | grep -i proving && continue
echo -n "remove /root/.lotusminer/sealed/$sealName ... "
rm -rf ${sealName} && echo 'ok' || echo 'fail'
fi
done

cd /root/.lotusminer/cache || exit 1
for cacheName in `ls | grep s-t01479781`
do
[ ".$cacheName" = "." ] && break
if ls /mnt/sealed/mainnet/storage/f01479781/1/cache/${cacheName} &> /dev/null
then
sectorId=`echo $cacheName | awk -F '-' '{print $NF}'`
[ ".${sectorId}" = "." ] && continue
[ "${sectorId}" -gt "778200" ] && continue
! lotus-miner sector status ${sectorId} | grep -i status | grep -i proving && continue
echo -n "remove /root/.lotusminer/cache/$cacheName ... "
rm -rf ${cacheName} && echo 'ok' || echo 'fail'
fi
done
