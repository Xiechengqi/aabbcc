#!/usr/bin/env bash

#
# 2022/02/11
# xiechengqi
# fetch lotus info to node-exporter prom file
#

tmpMetircPath="/data/metric/farcaster.prom.$$"
metricPath="/data/metric/farcaster.prom"

/usr/local/bin/lotus-exporter-farcaster.py | sed -i "s/@MINERID/@HOSTNAME/g" > ${tmpMetircPath}
mv /data/metric/farcaster.prom.$$ /data/metric/farcaster.prom
