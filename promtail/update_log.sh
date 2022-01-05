#!/usr/bin/env bash

#
# 2021/11/17
# xiechengqi
# 更新 promtail 需要监控的 log 软链接
#

logPath='/data/log' && mkdir -p ${logPath} || exit 1

log_regex_array=('/var/log/containers/window-post-miner-*.log' '/var/log/containers/winning-post-miner-*.log' '/var/log/containers/daemon-mainnet-*.log' '/var/log/containers/seal-miner-*.log')

for log_regex in ${log_regex_array[*]}
do
ls ${log_regex} &> /dev/null && ln -fs ${log_regex} ${logPath} || continue
done
