FROM ubuntu:latest

WORKDIR /touchgrass-server

# Install dependencies
RUN apt update \
 && apt upgrade -y \
 && apt install openjdk-17-jdk -y \
 && apt install mysql-server -y

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Configure MySQL
ENV MYSQL_USER=touchgrass
ENV MYSQL_PASSWORD=testpassword
ENV MYSQL_DATABASE=touchgrass
ENV MYSQL_HOST=localhost
ENV MYSQL_PORT=3306

RUN service mysql start \
 && mysql -u root -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE" \
 && mysql -u root -e "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'$MYSQL_HOST' IDENTIFIED BY '$MYSQL_PASSWORD'" \
 && mysql -u root -e "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'$MYSQL_HOST'" \
 && mysql -u root -e "FLUSH PRIVILEGES"

# Copy the project files
COPY . .

# Server Configuration
ENV SERVER_PORT=8080

# Install Maven
RUN service mysql start \
 && ./mvnw clean install

EXPOSE $SERVER_PORT

CMD ["bash", "-c", "service mysql start && ./mvnw spring-boot:run"]