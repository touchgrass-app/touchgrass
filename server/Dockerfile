FROM ubuntu:latest

WORKDIR /touchgrass-server

# Install dependencies
RUN apt update \
 && apt upgrade -y \
 && apt install openjdk-17-jdk -y \
 && apt install mysql-server -y

# Configure Java
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Configure MySQL
ENV MYSQL_USER=touchgrass
ENV MYSQL_DATABASE=touchgrass
ENV MYSQL_HOST=localhost
ENV MYSQL_PORT=3306

# Server Configuration
ENV SERVER_PORT=8080

# Copy the project files
COPY . .

# Copy application.properties
RUN cp src/main/resources/application.properties.template src/main/resources/application.properties

# Install Maven
RUN ./mvnw clean install -Dmaven.test.skip

EXPOSE $SERVER_PORT
VOLUME [ "/var/lib/mysql" ]

CMD ["bash", "startup.sh"]