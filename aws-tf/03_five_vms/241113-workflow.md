### 2024-11-13  19:60
---------------------

### Copy key to jumpserver
[ec2-user@home ~]$ scp -i key1.pem key2.pem ec2-user@172.31.48.249:/home/ec2-user/
### Enter to jumpserver
[ec2-user@home ~]$ ssh -i key1.pem ec2-user@172.31.48.249

[ec2-user@ip-172-31-48-249 ~]$ sudo ss -tuln
Netid  State   Recv-Q  Send-Q                     Local Address:Port    Peer Address:Port  Process  
udp    UNCONN  0       0                                0.0.0.0:68           0.0.0.0:*              
udp    UNCONN  0       0                                0.0.0.0:111          0.0.0.0:*              
udp    UNCONN  0       0                                0.0.0.0:683          0.0.0.0:*              
udp    UNCONN  0       0                              127.0.0.1:323          0.0.0.0:*              
udp    UNCONN  0       0        [fe80::4e0:1cff:feea:9a5f]%eth0:546             [::]:*              
udp    UNCONN  0       0                                   [::]:111             [::]:*              
udp    UNCONN  0       0                                   [::]:683             [::]:*              
udp    UNCONN  0       0                                  [::1]:323             [::]:*              
tcp    LISTEN  0       128                              0.0.0.0:22           0.0.0.0:*              
tcp    LISTEN  0       100                            127.0.0.1:25           0.0.0.0:*              
tcp    LISTEN  0       128                              0.0.0.0:111          0.0.0.0:*              
tcp    LISTEN  0       128                                 [::]:22              [::]:*              
tcp    LISTEN  0       128 

### Enter on RabbitMQ
[ec2-user@ip-172-31-48-249 ~]$ ssh -i key2.pem ec2-user@172.31.64.9
Last login: Wed Nov 13 17:01:02 2024 from 172.31.48.249
[ec2-user@ip-172-31-64-9 ~]$ sudo ss -tuln
Netid    State     Recv-Q    Send-Q       Local Address:Port        Peer Address:Port    Process    
udp      UNCONN    0         0                127.0.0.1:323              0.0.0.0:*                  
udp      UNCONN    0         0                    [::1]:323                 [::]:*                  
tcp      LISTEN    0         128                0.0.0.0:22               0.0.0.0:*                  
tcp      LISTEN    0         128                0.0.0.0:25672            0.0.0.0:*                  
tcp      LISTEN    0         1024               0.0.0.0:11211            0.0.0.0:*                  
tcp      LISTEN    0         128                   [::]:22                  [::]:*                  
tcp      LISTEN    0         4096                     *:4369                   *:*                  
tcp      LISTEN    0         128                      *:5672                   *:*                  
tcp      LISTEN    0         1024                 [::1]:11211               [::]:*   