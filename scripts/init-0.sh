echo "| $(hostname -I | awk '{print $1}') | $(hostname) | $(cat /proc/cpuinfo | grep processor | wc -l) | / | $(free -h | grep -E '^Mem:' | awk '{print $2}' | grep -E -o '[0-9]+') |"
