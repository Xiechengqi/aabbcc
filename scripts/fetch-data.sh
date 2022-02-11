# daemon
/usr/local/bin/lotus-exporter-farcaster.py > /var/lib/prometheus/node-exporter/farcaster.prom.$$
sed -i "s/@MINERID/@HOSTNAME/g" /var/lib/prometheus/node-exporter/farcaster.prom.$$

mv /var/lib/prometheus/node-exporter/farcaster.prom.$$ /var/lib/prometheus/node-exporter/farcaster.prom
