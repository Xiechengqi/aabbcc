#!/usr/bin/env bash

#
# xiechengqi
# 2021/12/04
# get Nvidia GPU metric
#

metricPath='/data/metric' 
if [ ! -d ${metricPath} ]
then
mkdir -p ${metricPath} || exit 1
fi

function main() {
# 收集指标
# 显卡数量
nvidia_num=$(nvidia-smi | grep GeForce | wc -l)

# 构建 prometheus textfile
cat > ${metricPath}/.nvidia-metric << EOF
# HELP nvidia_num get nvidia gpu number
# TYPE nvidia_num gauge
nvidia_num{ip="$(hostname -I | awk '{print $1}')", hostname="$(hostname)"} ${nvidia_num}
EOF

mv ${metricPath}/.nvidia-metric ${metricPath}/nvidia-metric.prom
}

main $@
