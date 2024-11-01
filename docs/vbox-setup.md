### 2024-10-29  11:11
---------------------

### PROVISIONING
###### Setup should be done in below mentioned order
| No | Service  | Description         | IP address    | Name  | Access Ports  |
|----|----------|---------------------|---------------|-------|---------------|
| 1. | MySQL    | Database server     | 192.168.56.15 | db01  |  TCP:3306     |
| 2. | Memcache | DB Caching server   | 192.168.56.14 | mc01  |TCP:11211/11111|
| 3. | RabbitMQ | Broker/Queue server | 192.168.56.16 | rmq01 | TCP:5672      |
| 4. | Tomcat   | Application server  | 192.168.56.12 | app01 | HTTP:8080     |
| 5. | Nginx    | Web server          | 192.168.56.11 | web01 | HTTP:80       |

###### All **IaC** see in the directory `./vbpx/`
###### To run the deployment:
```bash
vagrant up
bash vpro_ping.sh
```
###### To check if you have some issues:
```bash
vagrant ssh [Name]
netstat -tuln
ss -tuln
```

### To check if the Tomcat server with WebApp is OK
###### Go to the internet browser and check DB and RabbutMQ
```
http://192.168.56.12:8080
```
admin_vp
Rabbitmq initiated
Generated 2 Connections
6 Chanels 1 Exchage and 2 Que

```
http://192.168.56.11/index
```
DevOps