#!/bin/bash

# Configure MySQL
service mysql start

# Check if the database exists, and create it if it doesn't
if ! mysql -u root -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '$MYSQL_DATABASE'" | grep -q "$MYSQL_DATABASE"; then
  mysql -u root -e "CREATE DATABASE $MYSQL_DATABASE"
  mysql -u root -e "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'$MYSQL_HOST' IDENTIFIED BY '$MYSQL_PASSWORD'"
  mysql -u root -e "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'$MYSQL_HOST'"
  mysql -u root -e "FLUSH PRIVILEGES"
fi

./mvnw spring-boot:run