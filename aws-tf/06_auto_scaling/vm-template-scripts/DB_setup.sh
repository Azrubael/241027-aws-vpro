#!/bin/bash

# Start and enable the MariaDB service
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Create a temporary directory and navigate to it
mkdir -p /tmp/provisioning
cd /tmp/provisioning

# Download the database backup from S3
aws s3 cp "s3://${S3_BUCKET_NAME}/artifact/db_backup.sql" .

# Set the root password and flush privileges
sudo mysqladmin -u root password "$DATABASE_PASS"
sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"

# Create the accounts database
sudo mysql -u root -p"$DATABASE_PASS" -e "CREATE DATABASE accounts;"

# Import the database backup into the accounts database
sudo mysql -u root -p"$DATABASE_PASS" accounts < /tmp/provisioning/db_backup.sql

# Flush privileges again (optional)
sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES;"

# Restart the MariaDB service
sudo systemctl restart mariadb

: << 'DBTEST'
# Log in to MySQL:
mysql -u your_username -p
MariaDB [(none)]> show databases;
MariaDB [(none)]> select * from accounts.user;


```bash
#!/bin/bash
USERNAME="your_username"
PASSWORD="your_known_password"
# Try to log in to MySQL
mysql -u "$USERNAME" -p"$PASSWORD" -e "SELECT 1;" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "Password is correct for user $USERNAME."
else
    echo "Password is incorrect for user $USERNAME."
fi
```

# Вывод стартового скрипта можно найти в файле: 
sudo cat /var/log/cloud-init-output.log

# Сам скрипт, который был добавлен в качестве пользовательских данных, не сохраняется в виде файла на диске, но его можно просмотреть через метаданные
curl http://169.254.169.254/latest/user-data

DBTEST