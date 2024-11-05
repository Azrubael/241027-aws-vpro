#!/bin/bash
# The script to terminate AWS EC2 instances with the tag Server=MemcacheD

# Look for instances with tag Server=MemcacheD
INSTANCE_IDS=$(aws ec2 describe-instances \
    --filters "Name=tag:Server,Values=MemcacheD" "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].InstanceId' \
    --output text)

# Check if there were found any
if [ -z "$INSTANCE_IDS" ]; then
    echo "The instances with the tag 'Server=MemcacheD' not fount."
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