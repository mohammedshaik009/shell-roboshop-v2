#!/bin/bash

source ./common.sh
check_root

dnf module enable mysql:8.4 -y &>> $LOGS_FILE
dnf install mysql-server -y &>> $LOGS_FILE
VALIDATE $? "installing mysql-server"

systemctl --now enable mysqld &>> $LOGS_FILE
VALIDATE $? "enable and start mysql-server"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGS_FILE
VALIDATE $? "setting up Root password"

total_time
