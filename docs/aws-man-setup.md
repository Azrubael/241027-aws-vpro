### 2024-10-29  11:12
---------------------

### IP Table - from the branch 'vbox'
| No | Service  | Description         | IP address    | Name  | Access Ports  |
|----|----------|---------------------|---------------|-------|---------------|
| 1. | MySQL    | Database server     | 192.168.56.15 | db01  |  TCP:3306     |
| 2. | Memcache | DB Caching server   | 192.168.56.14 | mc01  |TCP:11211/11111|
| 3. | RabbitMQ | Broker/Queue server | 192.168.56.16 | rmq01 | TCP:5672      |
| 4. | Tomcat   | Application server  | 192.168.56.12 | app01 | HTTP:8080     |
| 5. | Nginx    | Web server          | 192.168.56.11 | web01 | HTTP:80       |



### 2024-10-30  10:45
---------------------
### IP Table with actual data
| No | Service  | Description  | IP address       | Name  | Access Ports |
|----|----------|--------------|------------------|-------|--------------|
| 1. | MySQL    | Database     | 172.19.100.7/16  | db01  |  TCP:3306    |
| 2. | Memcache | DB Caching   | 172.19.100.8/16  | mc01  |  TCP:11211   |
|    |          |              |                  |       |  UDP:11111   |
| 3. | RabbitMQ | Broker/Queue | 172.19.100.9/16  | rmq01 |  TCP:5672    |
| 4. | TomcatA  | Application  | 172.19.1.0/16    | app01 |  HTTP:8080   |
| 5. | TomcatB  | Application  | 172.19.1.0/16    | app01 |  HTTP:8080   |

### Work Plan
1. Login to AWS Account
2. Create an S3 bucket "az-$(date +%Y%m%d)"
3. Upload the application, scripts and supplementary files to S3 bucket
4. Create a Key Pair "key-$(date +%Y%m%d)" and upload it on AWS
5. Create a VPC and upload files for provisioning.
6. Create Security Groups:
- vpro-elb-sg (SG for the Elastic Load Balancer)
    + *Inbound* = HTTP > Port:80 > 0.0.0.0/0
    + *Inbound* = 'Custom TCP':80 > ::/0
    + *Inbound* = HTTPS > Port:443 > 0.0.0.0/0
    + *Inbound* = HTTPS > Port:443 > ::/0
    + *Outbond* = Allow all
- vpro-app-sg (SG for Tomcat9 instances)
    + *Inbound* = HTTP > Port:8080 > vpro-elb-sg (allow traffic from ELB)
    + *Outbond* = Allow all
- vpro-backend-sg (SG for backend services - MySQL, MemcacheD and RabbitMQ)
    + *Inbound* = MYSQL/Aurora > TCP:3306 > vpro-app-sg (to MySQL server)
    + *Inbound* = 'Custom TCP':11211 > vpro-app-sg (from Tomcat9 to MemcacheD)
    + *Inbound* = 'UDP':11111 > vpro-app-sg (from Tomcat9 to MemcacheD)
    + *Inbound* = 'Custom TCP':5672 > vpro-app-sg  (from Tomcat9 to RabbitMQ)
    + *Inbound* = 'All traffic' > vpro-backend-sg (allow all `internal` traffic)
    + *Outbond* = Allow all
7. Launch Instances with user data [bash scripts]
8. Upoad artifact to app01 instance with Tomcat9
9. Setup ELB with HTTPS [Cert form Amazon Certificate Manager]
10. Buy a new domain name in GoDaddy DNS [see 104]
11. Update IP to name mapping in route 53
12. Map ELP Endpoint to website name in Godaddy DNS
13. Validate
14. Build Autoscaling Group for Tomcat9 instances
15. Remove the infrastrusture


### 2024-11-07  20:17 - DEFAULT-VPC (SANDBOX)
---------------------
### IP Table with actual data
| No | Service  | Description  | IP address       | Name  | Access Ports |
|----|----------|--------------|------------------|-------|--------------|
| 1. | MySQL    | Database     | 172.31.64.7/16   | db01  |  TCP:3306    |
| 2. | Memcache | DB Caching   | 172.31.64.8/16   | mc01  |  TCP:11211   |
|    |          |              |                  |       |  UDP:11111   |
| 3. | RabbitMQ | Broker/Queue | 172.31.64.9/16   | rmq01 |  TCP:5672    |
| 4. | TomCatA  | Application  | 172.19.48.X/16   | app01 |  HTTP:8080   |
|    |          |              |                  |       |  SSH:22      |
| 5. | TomCatB  | Application  | 172.19.48.Y/16   | app01 |  HTTP:8080   |
|    |          |              |                  |       |  SSH:22      |
| 6. | Bastion  | Application  | 172.31.48.257/16 |bastion|  SSH:22      |
|    |          |              |                  |       |              |


### Work Plan
1. Write only python scripts
2. Create an S3 bucket "az-20241102"
3. Upload the application, scripts and supplementary files to S3 bucket
4. Create an AWS S3 bucket policy
5. Uploadpload files onto S3 bucket for provisioning.
6. Create Security Groups:
- vpro-elb-sg (SG for the Elastic Load Balancer)
    + *Inbound* = HTTP > Port:80 > 0.0.0.0/0
    + *Inbound* = 'Custom TCP':80 > ::/0
    + *Inbound* = HTTPS > Port:443 > 0.0.0.0/0
    + *Inbound* = HTTPS > Port:443 > ::/0
    + *Outbond* = Allow all
- FRONTEND-sg (SG for TomCat instances)
    + *Inbound* = HTTP > Port:8080 > vpro-elb-sg (allow traffic from ELB)
    + *Inbound* = 'SSH':22 > BASTION-sg (allow traffic from BASTION)
    + *Outbond* = Allow all
- BACKEND-sg (SG for backend services - MySQL, MemcacheD and RabbitMQ)
    + *Inbound* = MYSQL/Aurora > TCP:3306 > FRONTEND-sg (to MySQL server)
    + *Inbound* = 'Custom TCP':11211 > FRONTEND-sg (to MemcacheD)
    + *Inbound* = 'UDP':11111 > FRONTEND-sg (to MemcacheD)
    + *Inbound* = 'Custom TCP':5672 > FRONTEND-sg  (to RabbitMQ)
    + *Inbound* = 'SSH':22 > BASTION-sg  (to all)
    + *Inbound* = 'All TCP' > BACKEND-sg (allow all `internal` traffic)
    + *Outbond* = Allow all
- BASTION-sg (SG for bastion server)
    + *Inbound* = 'SSH':22 > from my local host
    + *Outbound* = Allow all
7. Create an Instance Profile to access S3 bucket from the instances
8. Download the provision fles from S3 bucket and launch instances with bash scripts. Create a new 'doorward-user' with the password. Grant the permissions to connect via SSH with the password.
9. Run 'bastion-server' and:
    - generate 'doorward-$(date +%Y%m%d)';
    - create a new 'doorward-user' with the password;
    - upload 'doorward-$(date +%Y%m%d)' to all the instances from the bastion server;
    - forbid to connect via SSH with the password;
    - allow to connect via SSH only with the key.
10. Check the connections via SSH to all the instances.
11. Setup ELB with HTTPS [Cert form Amazon Certificate Manager]
12. Buy a new domain name in GoDaddy DNS [see 104]
13. Update IP to name mapping in route 53
14. Map ELP Endpoint to website name in Godaddy DNS
15. Validate
16. Build Autoscaling Group for Tomcat9 instances
17. Remove the infrastrusture