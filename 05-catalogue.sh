#!/bin/bash

name=catalogue
source ./common.sh
check_root
app_setup
nodejs_setup
systemd_setup

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGS_FILE
VALIDATE $? "adding mongo.repo"

dnf install mongodb-mongosh -y  &>> $LOGS_FILE
VALIDATE $? "installing MongoDB-client"

INDEX=$(mongosh --host "mongodb.$domain_name" --quiet --eval 'db.getSiblingDB("catalogue").products.countDocuments()') &>> $LOGS_FILE
if [ -z "$INDEX" ] || [ "$INDEX" -eq 0 ]; then
    mongosh --host mongodb.$domain_name </app/db/master-data.js  &>> $LOGS_FILE
    VALIDATE $? "Load Products"
else
    echo -e "$TIMESTAMP [INFO] products already loaded ...$Y SKIPPING $N"
fi

app_restart
total_time