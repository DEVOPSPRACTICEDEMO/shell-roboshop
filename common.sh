#!/bin/bash

START_TIME=$(date +%s)
echo "Script started at: $(date)"
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
check_root(){
    if [ $USER_ID -ne 0 ]
    then
        echo -e "$R ERROR:: Please run this script with root access $N" | tee -a $LOG_FILE
        exit 1 #Give other than 0 upto 127
    else
        echo "You are running with root access" | tee -a $LOG_FILE
    fi
}

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

print_time(){
    END_TIME=$(date +%s)
    DIFF=$(($END_TIME - $START_TIME))
    echo -e "$Y Script completed in $DIFF seconds $N" | tee -a $LOG_FILE
    echo "Script ended at: $(date)" | tee -a $LOG_FILE
}