#!/usr/bin/env bash

#
# xiechengqi
# 2021/09/19
# 根据时间戳获取高度
#

timestamp=$1

height=$(echo "(${timestamp} - 1598306430) / 30" | bc)
time=$(TZ=UTC-8 date -d @${timestamp} +"%Y-%m-%d %H:%M:%S")
echo "${time} ${height}"
