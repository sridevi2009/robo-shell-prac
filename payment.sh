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

dnf install python36 gcc python3-devel -y &>> $LOGFILE

VALIDATE $? "installing python"

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

curl -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE

VALIDATE $? "downloading application code"

cd /app &>> $LOGFILE

unzip -o /tmp/payment.zip &>> $LOGFILE

VALIDATE $? "unzipping shipping"

pip3.6 install -r requirements.txt &>> $LOGFILE

VALIDATE $? "installing python dependencies"

#use absolute path because payment.service exists there, we cloned this payment.service in host

cp /home/centos/robo-shell-prac/payment.service /etc/systemd/system/payment.service &>> $LOGFILE

VALIDATE $? "copying systemd service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "daemon-reload"

systemctl enable payment &>> $LOGFILE

VALIDATE $? "enabling payment"

systemctl start payment &>> $LOGFILE

VALIDATE $? "starting payment"

