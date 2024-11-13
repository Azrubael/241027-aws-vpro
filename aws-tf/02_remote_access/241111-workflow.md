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
            ssh-keygen -t rsa -b 4096 -f ./env/anykey
            scp -i ./env/anykey.pem ./env/wavekey.pem ec2-user@<some_IP>:/home/ec2-user
            ssh -i ./env/anykey.pem ec2-user@<some_IP>
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


### 2024-11-12  20:18
---------------------
$ scp -i 241107-key.pem  vpro-key.pem ec2-user@100.26.209.190:/home/ec2-user
vpro-key.pem                                                      100% 1679    12.8KB/s   00:00 
$ ssh -i 241107-key.pem ec2-user@100.26.209.190
   ,     #_
   ~\_  ####_        Amazon Linux 2
  ~~  \_#####\
  ~~     \###|       AL2 End of Life is 2025-06-30.
  ~~       \#/ ___
   ~~       V~' '->
    ~~~         /    A newer version of Amazon Linux is available!
      ~~._.   _/
         _/ _/       Amazon Linux 2023, GA and supported until 2028-03-15.
       _/m/'           https://aws.amazon.com/linux/amazon-linux-2023/

[ec2-user@ip-172-31-48-249 ~]$ ls
vpro-key.pem
[ec2-user@ip-172-31-48-249 ~]$ ssh -i vpro-key.pem ec2-user@172.31.64.7
The authenticity of host '172.31.64.7 (172.31.64.7)' can't be established.
ECDSA key fingerprint is SHA256:qCmzINPs4HHfUwGqaare99KNALabL9DZTnMy0KFhv/8.
ECDSA key fingerprint is MD5:d5:5e:40:60:f9:b6:dd:9d:70:9d:5b:50:75:74:6c:d8.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '172.31.64.7' (ECDSA) to the list of known hosts.
   ,     #_
   ~\_  ####_        Amazon Linux 2
  ~~  \_#####\
  ~~     \###|       AL2 End of Life is 2025-06-30.
  ~~       \#/ ___
   ~~       V~' '->
    ~~~         /    A newer version of Amazon Linux is available!
      ~~._.   _/
         _/ _/       Amazon Linux 2023, GA and supported until 2028-03-15.
       _/m/'           https://aws.amazon.com/linux/amazon-linux-2023/

[ec2-user@ip-172-31-64-7 ~]$ 

