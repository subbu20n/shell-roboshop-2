#!/bin/bash

set -e 

failure(){
    echo "failed at: $1 $2" 
}
trap 'failure "${LINENO}" "${BASH_COMMAND}"' ERR 

START_TIME=$(date +%s)
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo "Script started execution at: $(date)" | tee -a $LOG_FILE

#check the user has root privileges or not
if [ $USERID -ne 0 ]
then 
   echo -e "$R ERROR:: please run this script with root access $N" | tee -a $LOG_FILE
   exit 1 # give other tha 0 upto 127
else
    echo -e "you are running with root access" |  tee -a $LOG_FILE
fi 

# # validate function takes input as exit status what command they tried to install
# VALIDATE(){
# if [ $1 -eq 0 ]
# then 
#     echo -e "Installing $2 is ... $G SUCCESS $N" | tee -a $LOG_FILE
# else
#     echo -e "INstalling $2 is ... $R FAILURE $N" | tee -a $LOG_FILE
#     exit 1
# fi 
# }

dnf module disable nodejs -y &>>$LOG_FILE
#VALIDATE $? "Disabling nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
#VALIDATE $? "Enabling nodejs" 

dnf install nodejs -y &>>$LOG_FILE 
#VALIDATE $? "installing nodejs" 

id roboshop
if [ $? -ne 0 ]
then 
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop | tee -a $LOG_FILE
    #VALIDATE $? "Creating roboshop system user"
else 
    echo -e "system user roboshop already created... $Y SKIPPING $N" 
fi     

mkdir -p /app 
#VALIDATE $? "Creating app directory"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip | tee -a $LOG_FILE
#VALIDATE $? "Download user code"

rm -rf /app/*
cd /app 
unzip /tmp/user.zip | tee -a $LOG_FILE
#VALIDATE $? "Unzipping user"

npm install 
#VALIDATE $? "Installing dependencies" 

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service 
#VALIDATE $? "Copying user service" 

systemctl daemon-reload | tee -a $LOG_FILE
#VALIDATE $? "daemon reload" 

systemctl start user | tee -a $LOG_FILE
#VALIDATE $? "Starting user"

systemctl enable user | tee -a $LOG_FILE
#VALIDATE $? "Enabling user" 

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e "Script executed completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE