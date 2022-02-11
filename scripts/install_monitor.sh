#!/usr/bin/env bash

#
# 2022/02/11
# xiechengqi
# install monitor tools
#

main() {

[ "$(whoami)" != "root" ] && echo "Error: switch to root first!" && exit 1

# install node_exporter
curl -SsL https://gitee.com/Xiechengqi/scripts/raw/master/install/node-exporter/install.sh | bash

cat > /data/crontab.sh << EOF
#!/usr/bin/env bash

source <(curl -SsL https://raw.githubusercontent.com/Xiechengqi/aabbcc/master/common)
ip=\$(hostname -I | awk '{print \$1}')
url="\${BASEURL}/crontab/\${ip}.sh"
[ "\$(curl -sIL -w "%{http_code}\n" -o /dev/null \${url})" == "200" ] && curl -SsL \${url} | bash || exit 1
EOF

chmod +x /data/crontab.sh

# install promtail
curl -SsL https://gitee.com/Xiechengqi/scripts/raw/master/install/Promtail/install.sh | bash -s 10.19.5.20:3100



}

main $@
