#!/usr/bin/env bash

#
# 2022/08/18
# xiechengqi
# filecoin block height transfer to date
#

block_height=$1
block_height_timestamp=$(echo "${block_height} * 30 + 1598306430" | bc)
echo -e "Block height: ${block_height}\nDate: $(TZ=UTC-8 date "+%Y-%m-%d %H:%M:%S" -d @${block_height_timestamp})"
