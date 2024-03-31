#!/bin/bash
ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo -e "Script Started $G EXECUTING $N at $G $TIMESTAMP $N" &>> $LOGFILE

VALIDATE() {
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ...$R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi        
}

if [ $ID -ne 0 ]
then    
    echo -e "$R ERROR: Please run this script with root access $N"
    exit 1
else
    echo -e "$Y you are root user $N"
fi

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $LOGFILE

VALIDATE $? "configuring yum repos"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $LOGFILE

VALIDATE $? "configure yum repos for rabbitmq"

dnf install rabbitmq-server -y &>> $LOGFILE

VALIDATE $? "installing rabbitmq"

systemctl enable rabbitmq-server &>> $LOGFILE

VALIDATE $? "enabling rabbitmq"

systemctl start rabbitmq-server &>> $LOGFILE

VALIDATE $? "starting rabbitmq"

rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE

VALIDATE $? "creating roboshop user"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGFILE

VALIDATE $? "set permissions to roboshop"