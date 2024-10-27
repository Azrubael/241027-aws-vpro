#!/bin/bash
declare -A ip_addr
declare -A ip_check

ip_addr["db01"]="192.168.56.15"
ip_addr["mc01"]="192.168.56.14"
ip_addr["rmq01"]="192.168.56.16"
ip_addr["app01"]="192.168.56.12"
ip_addr["web01"]="192.168.56.11"

for k in "${!ip_addr[@]}"; do
    if ping -c1 "${ip_addr[$k]}"; then
        ip_check[$k]="is OK"
    else
        ip_check[$k]="doesn't reachable"
    fi
done

echo
echo
for k in "${!ip_check[@]}"; do
    echo "Server $k with ip ${ip_addr[$k]} ${ip_check[$k]}."
done

: << 'IPTABLE'
| No | Service   | Description         | IP address    | Name  |
|----|-----------|---------------------|---------------|-------|
| 1. | MySQL     | Database server     | 192.168.56.15 | db01  |
| 2. | Memcache  | DB Caching server   | 192.168.56.14 | mc01  |
| 3. | RabbitMQ  | Broker/Queue server | 192.168.56.16 | rmq01 |
| 4. | Tomcat    | Application server  | 192.168.56.12 | app01 |
| 5. | Nginx     | Web server          | 192.168.56.11 | web01 |
IPTABLE