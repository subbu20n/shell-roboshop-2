#!/bin/bash

source ./common.sh
app_name=catalogue

check_root
app_setup
nodejs_setup

systemd_setup

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
dnf indtallm mongodb-mongosh -y
VALIDATE $? "Installing mongodb client"

STATUS=$(mongosh --host mongodb.subbuaws.site --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $STATUS -ne 0 ]
then
    mongosh --host mongodb.subbuaws.site </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Loading data into mongodb"
else
    echo -e "data is already loaded ... $Y SKIPPING $N"
fi        

print_time | tee -a $LOG_FILE