#!/bin/bash

source ./common.sh
app_name=redis

check_root

dnf module disable redis -y
VALIDATE $? "Disabling redis"

dnf module enable redis:7 -y
VALIDATE $? "Enablig redis"

dnf install redis -y
VALIDATE $? "INstalling redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Edited redis conf file to accept remote connections"

systemctl enable redis 
VALIDATE $? "Enabling redis"

Systemctl start redis 
VALIDATE $? "Starting redis"

print_time | tee -a $LOG_FILE