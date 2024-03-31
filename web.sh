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

dnf install nginx -y &>> $LOGFILE

VALIDATE $? "installing nginx"

systemctl enable nginx &>> $LOGFILE

VALIDATE $? "enabling nginx"

systemctl start nginx &>> $LOGFILE

VALIDATE $? "starting nginx"

http://<public-IP>:80 &>> $LOGFILE

VALIDATE $? "check the html page"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE

VALIDATE $? " CHECK HTML PAGE"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE

VALIDATE $? "downloading the roboshop app"

cd /usr/share/nginx/html &>> $LOGFILE

VALIDATE $? "Extrating frontend content"

unzip /tmp/web.zip &>> $LOGFILE

VALIDATE $? "unzipping web.zip"

cp /home/centos/robo-shell-prac/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOGFILE

VALIDATE $? "Nginx reverse proxy configuration"

systemctl restart nginx &>> $LOGFILE

VALIDATE $? "restarting nginx"