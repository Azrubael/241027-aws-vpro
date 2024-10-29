### 2024-10-29  11:12
---------------------

### IP Table
| No | Service  | Description         | IP address    | Name  | Access Ports  |
|----|----------|---------------------|---------------|-------|---------------|
| 1. | MySQL    | Database server     | 192.168.56.15 | db01  |  TCP:3306     |
| 2. | Memcache | DB Caching server   | 192.168.56.14 | mc01  |TCP:11211/11111|
| 3. | RabbitMQ | Broker/Queue server | 192.168.56.16 | rmq01 | TCP:5672      |
| 4. | Tomcat   | Application server  | 192.168.56.12 | app01 | HTTP:8080     |
| 5. | Nginx    | Web server          | 192.168.56.11 | web01 | HTTP:80       |

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