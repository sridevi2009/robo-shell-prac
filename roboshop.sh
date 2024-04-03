# creating aws instance , route53 records by using shellscript  concept
# ---------------------------------------------------------------------
# 1. we need to create ec2 instances
# 2. mongodb, mysql, shipping we are creating t3.small remaining t2.micro
# 3. creating route53 records, web public ip remaining private ip

# IAM-identity and access management
# -----------------------------------
# authentication---->username/password
# authorization
# authorization---> you need to have access to enter project bays

# ROles

# team manager --->super admin
# team  lead---> admin
# senior engineers----> normal access
# trainee--->read access

# user == person --->username/password =authentication

# authorization
# -------------
# roles and permissions

# user --> what is the role of user ? ---> what are the permissions attached to that role 

# permission
# ----------
# nouns and verbs
# aws --> ec2,vpc,route53,cdn, iam === aws resources
# resource
# ---------
# web, cart , catalogue, hostedzones ===nouns
# create, update, read, delete == actions ==verbs

# sivakumar == trainee
# ---------
# ec2 --> web --->have only read access

# sridevi == juniior devops engineer
# ----------------------------------

# ec2 ---> web --> read and update access

# sandya == senior engineer
# ------------------------
# ec2 ---> web --> create, read , update access

# aditya == team lead
# ------------------
# ec2 ---> web, crt, catalogue, ect ---> create, read, update

# akhila == team manager
# --------------------------

# ec2 --> web, cart, catalogue, etc ---> create, read, update, delete

# command to create ec2 instance thourgh cli
# ------------------------------------------------
# example:
# aws ec2 run-instances --image-id ami-03245ao778a88... --instance-type t2.micro --security-group-ids sg-012d7ean932f6

#!/bin/bash

#!/bin/bash

AMI=ami-0f3c7d07486cad139
SG_ID=sg-03c7377220fd23f2a #replace with your SG ID
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")
# INSTANCES=("catalogue")


ZONE_ID=Z06938882FFP9CG45JXHM # replace your zone ID
DOMAIN_NAME="gopisri.cloud"

for i in "${INSTANCES[@]}"
do
    if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
    then
        INSTANCE_TYPE="t3.small"
    else
        INSTANCE_TYPE="t2.micro"
    fi

    IP_ADDRESS=$(aws ec2 run-instances --image-id $AMI --instance-type $INSTANCE_TYPE --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query 'Instances[0].PrivateIpAddress' --output text)
    echo "$i: $IP_ADDRESS"

    #create R53 record, make sure you delete existing record
    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Creating a record set for cognito endpoint"
        ,"Changes": [{
        "Action"              : "UPSERT"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$i'.'$DOMAIN_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$IP_ADDRESS'"
            }]
        }
        }]
    }
        '
done

