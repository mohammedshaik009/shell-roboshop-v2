#!/bin/bash

LOGS_FOLDER=/var/log/roboshop
sudo mkdir -p $LOGS_FOLDER
sudo chown -R ec2-user:ec2-user $LOGS_FOLDER
sudo chmod -R 755 $LOGS_FOLDER
LOGS_FILE="$LOGS_FOLDER/$0.log"
SCRIPT_DIR=$(dirname "$(realpath "$0")")
domain_name=nazeer.shop
TIMESTAMP=$(date "+%m-%d-%Y %H:%M:%S")
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo -e "$TIMESTAMP [INFO] script started"

check_root(){
USER_ID=$(id -u)
#check root user or not
if [ $USER_ID -ne 0 ]; then
    echo -e "$TIMESTAMP [ERROR] $R please run this script with root access $Y" | tee -a $LOGS_FILE
    exit 1
fi
}

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$TIMESTAMP [ERROR] $2 is ...$R FAILED $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$TIMESTAMP [INFO] $2 is ...$G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

app_setup(){
    id roboshop &>> $LOGS_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop  &>> $LOGS_FILE
        VALIDATE $? "creating system user"
    else
        echo -e "$TIMESTAMP [INFO] system user already created ...$Y SKIPPING $N"
    fi

    rm -rf /app &>> $LOGS_FILE
    VALIDATE $? "removing app directory"

    mkdir -p /app &>> $LOGS_FILE
    VALIDATE $? "creating app directory"

    rm -rf /tmp/$name.zip &>> $LOGS_FILE
    VALIDATE $? "removing existing code"

    curl -L -o /tmp/$name.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/$name-v4.zip &>> $LOGS_FILE
    cd /app
    unzip /tmp/$name.zip &>> $LOGS_FILE
    VALIDATE $? "download and extract the code"
}
nodejs_setup(){
    dnf module disable nodejs -y &>> $LOGS_FILE
    dnf module enable nodejs:20 -y &>> $LOGS_FILE
    dnf install nodejs -y &>> $LOGS_FILE
    VALIDATE $? "installing nodejs"

    npm install &>> $LOGS_FILE
    VALIDATE $? "installing dependencies"
}
java_setup(){
    dnf module enable maven:3.9 -y &>> $LOGS_FILE
    dnf install maven java-25-openjdk-devel -y &>> $LOGS_FILE
    VALIDATE $? "installing maven and java"

    alternatives --set java "/usr/lib/jvm/java-25-openjdk/bin/java"
    VALIDATE $? "setting java 25 default to java 25 version"

    echo "export JAVA_HOME=$(dirname $(dirname $(readlink -f /usr/bin/java)))" > /etc/profile.d/java.sh
    source /etc/profile.d/java.sh
    echo "$JAVA_HOME"
    VALIDATE $? "setting up JAVA_HOME"

    cd /app
    mvn clean package &>> $LOGS_FILE
    VALIDATE $? "installing dependencies"

    mv target/shipping.jar shipping.jar &>> $LOGS_FILE
    VALIDATE $? "moving shipping.jar file"
}
python_setup(){
    dnf install python3.14 -y &>> $LOGS_FILE
    VALIDATE $? "installing python"

    python3.14 -m venv /app/.venv &>> $LOGS_FILE
    /app/.venv/bin/pip install -r requirements.txt &>> $LOGS_FILE
    VALIDATE $? "installing dependencies"
}
systemd_setup(){
    sed -i "s/DOMAIN_NAME/$domain_name/g" $SCRIPT_DIR/$name.service &>> $LOGS_FILE
    VALIDATE $? "changing domain_name"
    
    cp "$SCRIPT_DIR/$name.service" /etc/systemd/system/$name.service &>> $LOGS_FILE
    VALIDATE $? "creating systemd file"

    systemctl daemon-reload &>> $LOGS_FILE
    systemctl enable $name &>> $LOGS_FILE
    systemctl start $name &>> $LOGS_FILE
    VALIDATE $? "enable and start $name"
}
app_restart(){
    systemctl restart $name &>> $LOGS_FILE
    VALIDATE $? "restarting $name"
}

total_time(){
    echo -e "$TIMESTAMP [INFO] script executed in $SECONDS seconds"
}