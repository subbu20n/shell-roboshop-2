#!/bin/bash

source ./common.sh
app_name=redis

check_root

dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disabling redis"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enablig redis"

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "INstalling redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Edited redis conf file to accept remote connections"

systemctl enable redis  &>>$LOG_FILE
VALIDATE $? "Enabling redis"

systemctl start redis &>>$LOG_FILE
VALIDATE $? "Starting redis"

print_time | tee -a $LOG_FILE