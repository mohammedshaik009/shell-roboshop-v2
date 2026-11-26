#!/bin/bash

source ./common.sh
check_root

dnf moduel enable nginx:1.26 -y &>> $LOGS_FILE
dnf install nginx -y &>> $LOGS_FILE
VALIDATE $? "installing nginx"

systemctl --now enable nginx &>> $LOGS_FILE
VALIDATE $? "enable and start nginx"

rm -rf /usr/share/nginx/html/* &>> $LOGS_FILE
VALIDATE $? "removing existing code"

curl -L -o /tmp/frontend.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/frontend-v4.zip &>> $LOGS_FILE
cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>> $LOGS_FILE
VALIDATE $? "download and extract the code"

sed -i "s/DOMAIN_NAME/$domain_name/g" $SCRIPT_DIR/roboshop.conf &>> $LOGS_FILE
VALIDATE $? "changing domain_name"

cp $SCRIPT_DIR/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOGS_FILE
VALIDATE $? "roboshop configurations"

nginx -t &>> $LOGS_FILE
VALIDATE $? "nginx configurations"

systemctl restart nginx &>> $LOGS_FILE 
VALIDATE $? "restarting nginx"

total_time
