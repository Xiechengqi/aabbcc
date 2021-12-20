#!/usr/bin/env bash

#
# 2021/12/20
# xiechengqi
# get miner lucky value during 24h
#

minerId=$1
[ ".${minerId}" = "." ] && echo "Usage: curl -SsL https://raw.githubusercontent.com/Xiechengqi/aabbcc/master/scripts/get_lucky_value.sh [minerId]"
printf %.2f $(echo "$(curl -SsL 'https://filfox.info/api/v1/address/${minerId}/mining-stats?duration=24h' | jq -r .luckyValue) * 100" | bc)
