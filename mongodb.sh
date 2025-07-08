#!/bin/bash

USER_ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOGS_FOLDER
echo -e "$Y Script started executing at: $(date) $N" | tee -a $LOG_FILE

#Check the user has root privileges or not
if [ $USER_ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N" | tee -a $LOG_FILE
    exit 1 #Give other than 0 upto 127
else
    echo "You are running with root access" | tee -a $LOG_FILE
fi

#Validate function takes input as exit status, what command they tried to install
VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is ... $G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}

cp mongo.repo /etc/yum.repos.d/mongodb.repo
VALIDATE $? "Copying MongoDB repo"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "Installing mongodb server"

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "Enabling MongoDB"
systemctl start mongod &>>$LOG_FILE
VALIDATE $? "Starting MongoDB"

sed -i -e 's/127.0.0.0/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Editing MongoDB conf file for remote connections"

systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "Restarting MongoDB"


