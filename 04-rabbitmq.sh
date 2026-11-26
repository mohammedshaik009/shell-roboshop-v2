#!/bin/bash

source ./common.sh
check_root

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>> $LOGS_FILE
VALIDATE $? "adding rabbitmq.repo"

dnf install erlang rabbitmq-server -y &>> $LOGS_FILE
VALIDATE $? "installing rabbitmq-server"

systemctl --now enable rabbitmq-server &>> $LOGS_FILE
VALIDATE $? "enable and start rabbitmq-server"

rabbitmqctl list_users | grep -qw "roboshop" &>> $LOGS_FILE
if [ $? -ne 0 ]; then
    rabbitmqctl add_user roboshop roboshop123 &>> $LOGS_FILE
    VALIDATE $? "adding roboshop user"
else
    echo -e "$TIMESTAMP [INFO] roboshop user already added ...$Y SKIPPING $N"
fi

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGS_FILE
VALIDATE $? "setting up permissions"

