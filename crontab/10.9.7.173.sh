#!/usr/bin/env bash

promtail_update_log

ps axu | grep '/data/client-exporter/client-exporter.py' &> /dev/null || nohup python3 /data/client-exporter/client-exporter.py &> /dev/null &
