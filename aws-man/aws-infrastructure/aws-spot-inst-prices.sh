#!/bin/bash

# N.Virginia, Frankfurt, Ireland
REGION=( "eu-central-1"
        "us-east-1"
        "eu-west-1" )
instance="t2.micro"


for zone in ${REGION[@]}; do
    echo "### Actual prices for Linux instance $instance in the Region $zone"
    aws ec2 describe-spot-price-history \
        --instance-types $instance \
        --start-time $(date -u +"%Y-%m-%dT%H:%M:%SZ") \
        --product-descriptions "Linux/UNIX" \
        --region $REGION
    echo
done
