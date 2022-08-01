for i in `ls /root/.lotusminer/cache | awk -F '-' '{print $NF}'`; do echo -n "$i " && lotus-miner sectors status $i | grep -i status | awk '{print $NF}'; done
