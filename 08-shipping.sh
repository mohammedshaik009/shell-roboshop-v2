#!/bin/bash

name=shipping
source ./common.sh
check_root
app_setup
java_setup
systemd_setup

dnf install mysql -y &>> $LOGS_FILE
VALIDATE $? "installing mysql-client"

INDEX=$(mysql -h mysql.$domain_name -u root -pRoboShop@1 -sN -e "SELECT COUNT(*) FROM information_schema.SCHEMATA WHERE SCHEMA_NAME = 'cities';") 2>> $LOGS_FILE
if [ -z "$INDEX" ] || [ $INDEX -eq 0 ]; then
    mysql -h mysql.$domain_name -uroot -pRoboShop@1 < /app/db/master-data.sql &>> $LOGS_FILE         
    mysql -h mysql.$domain_name -uroot -pRoboShop@1 < /app/db/app-user.sql  &>> $LOGS_FILE
    VALIDATE $? "Load Data"
else
    echo -e "$TIMESTAMP [INFO] Data already loaded ...$Y SKIPPING $N"
fi

app_restart
total_time
