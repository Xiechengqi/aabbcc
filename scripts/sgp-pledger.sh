#!/usr/bin/env bash

#
# 2021/12/16
# xiechengqi
# disable / enable /build SGP jenkins pledger job
#

usage() {
echo "Usage: bash $0 [disable|enable|build]" && exit 0
}

start="$1"
end="$2"
action="$3"
[[ "$action" =~ "disable|enable|build" ]] || usage

for id in `seq -f "%03g" ${start} ${end}`
do
echo -n "${action} job/pledger-miner${id}/ ... "
jcli job ${action} job/pledger-miner${id}/ && echo 'ok' || echo 'fail'
done
