#!/bin/bash

# Configure MySQL
service mysql start
mysql -u root -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE"
mysql -u root -e "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'$MYSQL_HOST' IDENTIFIED BY '$MYSQL_PASSWORD'"
mysql -u root -e "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'$MYSQL_HOST'"
mysql -u root -e "FLUSH PRIVILEGES"

./mvnw spring-boot:run