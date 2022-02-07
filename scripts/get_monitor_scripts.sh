#!/usr/bin/env bash

#
# 2022/02/07
# xiechengqi
# install monitor scripts
# usage: curl -SsL https://raw.githubusercontent.com/Xiechengqi/aabbcc/master/scripts/get_monitor_scripts.sh | bash -s [minerId]
#

minerId=$1

cat > /usr/local/bin/lotus-exporter-farcaster.py << EOF
/usr/local/bin/lotus-exporter-farcaster.py > /var/lib/prometheus/node-exporter/farcaster.prom.$$
sed -i "s/${minerId}/$(hostname)/g" /var/lib/prometheus/node-exporter/farcaster.prom.$$
mv /var/lib/prometheus/node-exporter/farcaster.prom.$$ /var/lib/prometheus/node-exporter/farcaster.prom
mv /var/lib/prometheus/node-exporter/farcaster.prom /data/
mv /data/farcaster.prom /data/metrics
EOF
