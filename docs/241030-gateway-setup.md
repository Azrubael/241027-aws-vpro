### 2024-10-30  12:29
---------------------

*The order to create a VPC and a subnet with the public access*
---------------------------------------------------------------

```bash
### 1. Create a VPC:
aws ec2 create-vpc --cidr-block 10.0.0.0/16 --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=MyVPC}]'

### 2. Note the VPC ID from the output of the previous command. You'll need it for the next steps.

### 3. Create a subnet within the VPC:
aws ec2 create-subnet --vpc-id <vpc-id> --cidr-block 10.0.1.0/24 --availability-zone us-east-1a --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=MyPublicSubnet}]'
#### Replace <vpc-id> with the actual VPC ID from step 2.

### 4. Create an Internet Gateway:
aws ec2 create-internet-gateway --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=MyIGW}]'

### 5. Attach the Internet Gateway to your VPC:
aws ec2 attach-internet-gateway --vpc-id <vpc-id> --internet-gateway-id <igw-id>
#### Replace <vpc-id> with your VPC ID and <igw-id> with the Internet Gateway ID from the previous step.

### 6. Create a route table for the VPC:
aws ec2 create-route-table --vpc-id <vpc-id> --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=MyRouteTable}]'

### 7. Add a route to the route table that directs internet-bound traffic to the Internet Gateway:
aws ec2 create-route --route-table-id <rtb-id> --destination-cidr-block 0.0.0.0/0 --gateway-id <igw-id>
#### Replace <rtb-id> with the route table ID from step 6 and <igw-id> with your Internet Gateway ID.

### 8. Associate the route table with the subnet:
aws ec2 associate-route-table --subnet-id <subnet-id> --route-table-id <rtb-id>
#### Replace <subnet-id> with your subnet ID and <rtb-id> with your route table ID.

### 9. Finally, enable auto-assign public IP addresses for the subnet:
aws ec2 modify-subnet-attribute --subnet-id <subnet-id> --map-public-ip-on-launch
```
