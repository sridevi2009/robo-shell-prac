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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOGFILE

VALIDATE $? "installing repo files as a rpm"

dnf module enable redis:remi-6.2 -y &>> $LOGFILE

VALIDATE $? "enabling redis package version 6.2"

dnf install redis -y &>> $LOGFILE

VALIDATE $? "installing redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>> $LOGFILE

VALIDATE $? "remote acces"

systemctl enable redis &>> $LOGFILE

VALIDATE $? "enabling redis"

systemctl start redis &>> $LOGFILE

VALIDATE $? "starting redis"