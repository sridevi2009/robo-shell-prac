#!/bin/bash
ID=$[ id -u ]
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo -e "$Y Script Started Executing $N"

VALIDATE() {
    if [ $1 -ne 0 ]
    then 
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ...$G SUCCESS $N"
    fi    
}

if [ $ID -ne 0 ]
then 
    echo -e "$R ERROR: Please run this script with root access $N"
    exit 1
else
    echo -e "$Y you are root user"
fi

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "disabling the nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "enabling the nodejs"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "installing nodejs"

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "creation roboshop"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi    

mkdir -p /app  &>> $LOGFILE

VALIDATE $? "creating app directory"

curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE

VALIDATE $? "downloading application code"

cd /app &>> $LOGFILE

unzip -o /tmp/cart.zip &>> $LOGFILE

VALIDATE $? "unzipping cart"

npm install  &>> $LOGFILE

VALIDATE $? "installing npm dependencies"

#use absolute path because cart.service exists there, we cloned this cart.service in host

cp /home/centos/robo-shell-prac/cart.service /etc/systemd/system/cart.service &>> $LOGFILE

VALIDATE $? "copying systemd service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "daemon-reload"

systemctl enable cart &>> $LOGFILE

VALIDATE $? "enabling cart"

systemctl start cart &>> $LOGFILE

VALIDATE $? "starting cart"



