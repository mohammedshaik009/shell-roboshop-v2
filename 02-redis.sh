#!/bin/bash

source ./common.sh
check_root

dnf module disable redis -y &>> $LOGS_FILE
dnf module enable redis:7 -y &>> $LOGS_FILE
dnf install redis -y &>> $LOGS_FILE
VALIDATE $? "installing redis"

systemctl --now enable redis &>> $LOGS_FILE
VALIDATE $? "enable and start redis"

sed -i -e 's/^bind 127.0.0.1/bind 0.0.0.0/g' -e 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf &>> $LOGS_FILE
VALIDATE $? "allow remote connections to all"

systemctl restart redis &>> $LOGS_FILE
VALIDATE $? "restarting redis"

time_total