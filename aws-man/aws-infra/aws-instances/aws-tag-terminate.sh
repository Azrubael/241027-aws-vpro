#!/bin/bash
# The script to terminate AWS EC2 instances with
# the tag key $1 and value $2
# Hints: $1=Server, $2=MySQL, $1=Server $2=Memcached, $1=Server $2=RabbitMQ

TAG_KEY=$1
TAG_VALUE=$2

if [ -z "$TAG_KEY" ] || [ -z "$TAG_VALUE" ]; then
    echo "Usage: $0 <tag-key> <tag-value>"
    exit 1    
fi

# Look for instances with tag Server=MySQL
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
    echo "All instances with the tag $TAG_KEY=$TAG_VALUE are terminating."
else
    echo "Something went wrong."
    exit 1
fi