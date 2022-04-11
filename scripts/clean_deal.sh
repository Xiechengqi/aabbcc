#!/usr/bin/env bash

# 2022/04/11
# xiechengqi
# clean /scratch/deal_data
#


main() {

while :
do

dealDataPath="/scratch/deal_data"
ls ${dealDataPath} &> /dev/null || exit 1
# max local deal data 3145728MB (3TB)
maxData="3145728"
# log file path
logDirPath="/data/logs/deal_data" && mkdir -p ${logDirPath}
logFilePath="${logDirPath}/clean.log"

currentDataSize=$(du -sm ${dealDataPath} | awk '{print $1}')
echo "【$(date "+%Y-%m-%d %H:%M:%S")】 ${dealDataPath} ... ${currentDataSize}MB" >> ${logFilePath}

if [ "${currentDataSize}" -gt "${maxData}" ]
then

echo "【$(date "+%Y-%m-%d %H:%M:%S")】 clean ${dealDataPath} ... " >> ${logFilePath}
find ${dealDataPath} -mmin +180 -type f -name "*" -exec rm -f {} \;

fi

echo "【$(date "+%Y-%m-%d %H:%M:%S")】 waiting for 3h ... " >> ${logFilePath}
sleep 3h

done


}

main $@
