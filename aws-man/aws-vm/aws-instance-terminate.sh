#!/bin/bash

# Check if ID passed
if [ -z "$1" ]; then
    echo "Использование: $0 <instance-id>"
    exit 1
fi

INSTANCE_ID=$1

# Check the state of the instance
INSTANCE_STATE=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query 'Reservations[0].Instances[0].State.Name' --output text)

if [ "$INSTANCE_STATE" == "running" ]; then
    echo "The instance $INSTANCE_ID is in the state: $INSTANCE_STATE."
    echo "Terminating the instance $INSTANCE_ID..."
    
    # Terminating the instance
    aws ec2 terminate-instances --instance-ids "$INSTANCE_ID"
    
    # Status check
    if [ $? -eq 0 ]; then
        echo "The instance $INSTANCE_ID is terminating."
    else
        echo "An error of terminating the instance $INSTANCE_ID."
    fi
else
    echo "The instance $INSTANCE_ID is in the state: $INSTANCE_STATE. Termination doesn't need."
fi
