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

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo -e "Script Started $G EXECUTING $N at $G $TIMESTAMP $N" &>> $LOGFILE

VALIDATE() {
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ...$R FAILED $N"
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi        
}

if [ $ID -ne 0 ]
then    
    echo -e "$R ERROR: Please run this script with root access $N"
    exit 1
else
    echo "$Y you are root user $N"
fi

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "copied mongo repo"

dnf install mongodb-org -y  &>> $LOGFILE

VALIDATE $? "install mongodb"

systemctl enable mongod &>> $LOGFILE

VALIDATE $? "enable mongod"

systemctl start mongod &>> $LOGFILE

VALIDATE $? "starting mongd"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE

VALIDATE $? "remote access to server"

systemctl restart mongod &>> $LOGFILE

VALIDATE $? "restarting mongod"