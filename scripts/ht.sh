#!/usr/bin/env bash

#
# xiechengqi
# 2021/08/19
# 根据高度获取时间
#

height=$1

block_height_timestamp=$(echo "${height} * 30 + 1598306430" | bc)
time="$(TZ=UTC-8 date "+%Y-%m-%d %H:%M:%S" -d @${block_height_timestamp})"
echo "time ${time}"

date="$(TZ=UTC-8 date "+%Y-%m-%d" -d @${block_height_timestamp})"

[ "$(date -d "$date" +%w)" = "0" ] && weekDay="7" || weekDay="$(date -d "$date" +%w)"
first_week_day="$date"-$(($weekDay-1))"days"
end_week_day="$date"+$((7-$weekDay))"days"
#获得这周第一天的日期
start_week=`date -d $first_week_day +%Y%m%d`
#获得这周最后一天的日期
end_week=`date -d $end_week_day +%Y%m%d`
echo "week $start_week-$end_week"

month_first_date=$(date -d "$date" +%Y%m01)
next_month_first_date=$(date -d "${month_first_date} next month" +%Y%m%d)
month_last_date=$(date -d "${next_month_first_date} last day" +%Y%m%d)
echo "month ${month_first_date}-${month_last_date}"
