#!/bin/bash

# Put some custom code here to notify monitoring ex. slack notification, zabbix trigger.
echo "$(date '+%Y-%m-%d %H:%M:%S') Recording stopped..." >> /var/log/racksview/recording.log