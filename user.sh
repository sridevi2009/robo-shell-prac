# SED editor: streamline editor
# cp /etc/passwd passwd
# cat passwd
# sed -e '1 a I am learning shell script'<file name>
# sed -e '1 a i am learning shell script' passwd
# sed -e '2 a I am learning shell script' passwd
# temporary editor= -e
# permanant editor= -i
# sed -i '1 a im learning shell script' passwd
# sed -i '1 i Im leaning shell script' passwd
# here i indicates= insert, which ia going to print this line before 1st line
# sed -e 's/word-to-find/word-to-replace/'
# sed -e 's/sbin/SBIN/' passwd {s=substitution} to replace the word
# sed -e 's/sbin/SBIN/g' passwd {g= will replace all words in that file}
# sed -e '1d' passwd {to delete the lines}
# sed -e '/learning/ d' passwd {to delte particular word in content}


#!/bin/bash
ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGODB_HOST=mongodb.gopisri.cloud

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

curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE

VALIDATE $? "downloading application code"

cd /app &>> $LOGFILE

unzip -o /tmp/user.zip &>> $LOGFILE

VALIDATE $? "unzipping user"

npm install  &>> $LOGFILE

VALIDATE $? "installing npm dependencies"

#use absolute path because catalogue.service exists there, we cloned this catalogue.service in host

cp /home/centos/robo-shell-prac/user.service /etc/systemd/system/user.service &>> $LOGFILE

VALIDATE $? "copying systemd service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "daemon-reload"

systemctl enable user &>> $LOGFILE

VALIDATE $? "enabling user"

systemctl start user &>> $LOGFILE

VALIDATE $? "starting  user"

cp /home/centos/robo-shell-prac/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "copying repo file"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "installing mongodb client"

mongo --host $MONGODB_HOST</app/schema/user.js &>> $LOGFILE

VALIDATE $? "loading schema{user data into mongodb}"







