#!/bin/bash

TAG_KEY="Server"
TAG_VALUE="TomCat"
echo "Terminating the instances with tag $TAG_KEY=$TAG_VALUE..."

# Look for instances with tag $TAG_KEY=$TAG_VALUE
INSTANCE_IDS=$(aws ec2 describe-instances \
    --filters "Name=tag:$TAG_KEY,Values=$TAG_VALUE" "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].InstanceId' \
    --output text)

# Check if there were found any
if [ -z "$INSTANCE_IDS" ]; then
    echo "The instances with the tag $TAG_KEY=$TAG_VALUE didn't find."
    exit 0
fi

# Terminate found instances
echo "Found instances: $INSTANCE_IDS"
echo "Terminating the instances..."

aws ec2 terminate-instances --instance-ids $INSTANCE_IDS

# Check the status
if [ $? -eq 0 ]; then
    echo "All instances are terminating."
else
    echo "Something went wrong."
fi