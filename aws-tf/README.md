### 2024-11-11  13:05
---------------------

./01_simplest
##### A successful attempt to create two servers (bastion and backend) in the default VPC. But the question of interaction via SSH between them has not yet been resolved. Bastion jump server is in the public subnet and backend db server is in the private subnet.

./02_remote_access
##### The next attempt with the proper setup of the both above described servers. It is a successfull attempt to run on AWS three servers: Bastion [jump01], TomCat [app01], MySQL [db01]. 
##### Also it has 'bastion NAT' to connect backend with WAN.
##### This configuration was run on the default VPC with two subnets.

./03_five_vms
##### The more complicate variant with the next servers:
- Bastion [jump01]
- TomCat [app01]
- MySQL [db01]
- MemcacheD [mc01]
- RabbitMQ [rmq01]
##### Also it has 'bastion NAT' to connect backend with WAN.
##### This configuration was run on the default VPC with two subnets.