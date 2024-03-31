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

dnf module disable mysql -y &>> $LOGFILE

VALIDATE $? "disabling mysql"

cp /home/centos/robo-shell-prac/mongo.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE

VALIDATE $? "setup repo file"

dnf install mysql-community-server -y &>> $LOGFILE

VALIDATE $? "installing mysql client "

systemctl enable mysqld &>> $LOGFILE

VALIDATE $? "enabling mysql"

systemctl start mysqld &>> $LOGFILE

VALIDATE $? "starting mysql"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE

VALIDATE $? "changing roboshop password"

mysql -uroot -pRoboShop@1 &>> $LOGFILE

VALIDATE $? "Checking new password"