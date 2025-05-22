#!/bin/bash
app_name=mysql
source ./common.sh

check_root

echo "please enter root password to setup"
read -s $MYSQL_ROOT_PASSWORD

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing mysql server"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabling mysql"

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "Starting mysql"

mysql_secure_installation --set-root-pass $MYSQL_ROOT_PASSWORD &>>$LOG_FILE
VALIDATE $? "setting mysql root password"

print_time | tee -a $LOG_FILE