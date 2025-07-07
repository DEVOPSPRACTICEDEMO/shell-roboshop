#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-050db45fd22113a83"
INSTANCES=("mongodb" "redis" "catalogue" "user" "cart" "shipping" "payment" "frontend" "dispatch" "rabbitmq" "mysql")
ZONE_ID= "Z07092431FXHTW58PX8NM"
DOMAIN_NAME="skptech.site"

for instance in ${INSTANCES[@]}
do 
    INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --count 1 --instance-type t2.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=test}]" --query 'Instances[0].InstanceId' --output text)    
    if [$instance != "frontend"]
    then
        IP= $(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
    else
        IP= $(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
    fi
    echo "Instance $instance created with ID: $INSTANCE_ID and IP: $IP"

    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID\
    --change-batch '
    {
        "Comment": "Creating or Updating a record set for cognito endpoint"
        ,"Changes":[{
        "Action"        : "UPSERT"
        ,"ResourceRecordSet" : {
            "Name"          : "$instance'.$DOMAIN_NAME"
            ,"Type"         : "A"
            ,"TTL"          : 1
            ,"ResourceRecords" : [{
                "Value"     : "'$IP'"
            }] 
        }
        }]
    }'
done


