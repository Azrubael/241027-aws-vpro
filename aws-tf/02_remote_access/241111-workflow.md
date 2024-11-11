### 2024-11-11 13:22
--------------------

#### Plan:
----------
A cloud infrastructure on AWS.
To do the next steps:
- get the VPC ID by the tag 'Name'=$VPC_NAME;
- check if one of the subnets in VPC ID has the tag 'Name'=$FRONTEND_SUBNET_NAME and assign its cidr to $FRONTEND_CIDR. If the VPC haven't the tag 'Name'=$FRONTEND_NAME, assign the tag to the subnet with $FRONTEND_CIDR;
- assign subnet ID of $FRONTEND_CIDR to $FRONT_ID;
- check if one of the subnets in VPC ID has the tag 'Name'=$BACKEND_SUBNET_NAME  and assign its cidr to $BACKEND_CIDR. If the VPC haven't the tag 'Name'=$BACKEND_NAME, assign the tag to the subnet with $BACKEND_CIDR;
- assign subnet ID of $BACKEND_CIDR to $BACK_ID;
- create a security group $FRONTEND_SG to allow ingress from '0.0.0.0/0' via SSH:22 and HTTP:8080;
- create a security group $BACKEND_SG to allow ingress only from $FRONTEND_CIDR;
- generate "doorward" ssh security key manually and place it in './.env/' directory:
            ssh-keygen -t rsa -b 2048 -f ./doorward
- create "bastion-script.sh" to do the next:
    + create a user "doorward";
    + add a user "doorward" to the group "sudo";
    + upload both public and private key to an instance 'bastion' for user "doorward";
- create "userdata-script.sh" to do the next:
    + create a user "doorward";
    + add a user "doorward" to the group "sudo";
    + upload public key "doorward" to an instance 'backend';
- run one EC2 instance 'bastion' with the next parameters:
    + instance-type "t.2micro";
    + image-id $OS_IMAGE_ID (Amazon Linux 2, ami-0984f4b9e98be44bf)
                            ~~(Minimal Ubuntu 20.04 LTS - Focal, ami-02666e8069b227307)~~;
    + key-name "vpro-key";
    + subnet ID $FRONT_ID;
    + associate a pulblic IP addess: true;
    + private IPv4=$BASTION_IP;
    + credit-specification: standard;
    + assign a tags: 'Name'='jump01', 'Server'='Bastion';
    + run the script 'jump-script.sh' to upload ssh keys;
- run one EC2 instance 'backend' with the next parameters:
    + instance-type "t.2micro";
    + image-id $OS_IMAGE_ID (Amazon Linux 2, ami-0984f4b9e98be44bf)
                            ~~(Minimal Ubuntu 20.04 LTS - Focal, ami-02666e8069b227307)~~;
    + key-name "vpro-key";
    + subnet ID $BACK_ID;
    + associate a pulblic IP addess: false;
    + private IPv4=$BACKEND_IP;
    + credit-specification: standard;
    + assign a tag 'Name'='db01', 'Server'='MySQL';
    + run the script 'db-script.sh' to add the public ssh key.

