#!/usr/bin/env bash

#
# 2022/02/12
# xiechengqi
# install lotus-exporter-farcaster exporter and add crontab job
#


main() {

miner_id=$1
miner_hostname=$2
miner_url=$3
miner_token=$4
daemon_url=$5
daemon_token=$6

# download lotus exporter and modify api info
curl -SsL https://raw.githubusercontent.com/Xiechengqi/aabbcc/master/scripts/lotus-exporter-farcaster.py -o /usr/local/bin/lotus-exporter-farcaster.py
chmod +x /usr/local/bin/lotus-exporter-farcaster.py
sed -i "s#@MINER_URL#${miner_url}#g; s/@MINER_TOKEN/${miner_token}/g; s/@DAEMON_URL#${daemon_url}#g; s/@DAEMON_TOKEN/${daemon_token}/g" /usr/local/bin/lotus-exporter-farcaster.py

# modify metric file
curl -SsL https://raw.githubusercontent.com/Xiechengqi/aabbcc/master/scripts/fetch-data.sh -o /usr/local/bin/fetch-data.sh
chmod +x /usr/local/bin/fetch-data.sh
sed -i "s#@MINERID#${miner_id}#g; s#@HOSTNAME#${miner_hostname}#g" /usr/local/bin/fetch-data.sh

# add crontab job
curl -SsL https://raw.githubusercontent.com/Xiechengqi/aabbcc/master/scripts/lotus-exporter-farcaster -o /etc/cron.d/lotus-exporter-farcaster

}

main $@
