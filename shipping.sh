#!/bin/bash

source ./common.sh
app_name=shipping

check_root

app_setup
maven_setup

systemd_setup

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Installing mysql"

mysql -h mysql.subbuaws.site -uroot -p$MYSQL_ROOT_PASSWORD -e 'use cities' &>>$LOG_FILE

if [ $? -ne 0 ]
then 
    mysql -h mysql.subbuaws.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/schema.sql &>>$LOG_FILE
    mysql -h mysql.subbuaws.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/app-user.sql &>>$LOG_FILE
    mysql -h mysql.subbuaws.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/master-data.sql &>>$LOG_FILE
else
    echo -e "data is already loaded into mysql ... $Y SKIPPING $N" &>>$LOG_FILE
fi

print_time | tee -a $LOG_FILE