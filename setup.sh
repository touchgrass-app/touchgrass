#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

check_prerequisites() {
    if ! command_exists brew; then
        echo -e "${RED}Error: Homebrew must be installed first${NC}"
        echo -e "${BLUE}[ACTION REQUIRED] Run this command in your terminal:${NC}"
        echo -e "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        echo -e "${YELLOW}Then run this setup script again${NC}"
        exit 1
    fi

    if ! command_exists xcode-select; then
        echo -e "${RED}Error: Xcode Command Line Tools must be installed first${NC}"
        echo -e "${BLUE}[ACTION REQUIRED] Run this command in your terminal:${NC}"
        echo -e "xcode-select --install"
        echo -e "${YELLOW}Then run this setup script again${NC}"
        exit 1
    fi

    if [ ! -d "/Applications/Xcode.app" ]; then
        echo -e "${RED}Error: Xcode must be installed first${NC}"
        echo -e "${BLUE}[ACTION REQUIRED] Install Xcode from the App Store${NC}"
        echo -e "${YELLOW}Then run this setup script again${NC}"
        exit 1
    fi
}

wait_for_mysql() {
    for i in {1..30}; do
        if mysqladmin ping -u root --silent; then
            return 0
        fi
        sleep 1
    done
    echo -e "${RED}Error: MySQL failed to start${NC}"
    return 1
}

check_mysql() {
    if ! command_exists mysql; then
        brew install mysql
    fi

    if ! mysqladmin ping -u root --silent 2>/dev/null; then
        brew services stop mysql
        brew services start mysql
        wait_for_mysql
    fi
}

generate_password() {
    openssl rand -base64 12
}

echo -e "${GREEN}Setting up TouchGrass...${NC}"

check_prerequisites

if ! command_exists java; then
    brew install openjdk@17
fi

if ! command_exists flutter; then
    brew install flutter
fi

check_mysql

if ! MYSQL_PASSWORD=$(generate_password); then
    echo -e "${RED}Error: Failed to generate secure password${NC}"
    exit 1
fi

echo -e "\n${BLUE}[ACTION REQUIRED] MySQL Security Setup${NC}"
echo -e "You will now be prompted to secure your MySQL installation."
echo -e "Recommended settings:"
echo -e "1. Set root password: ${GREEN}Yes${NC}"
echo -e "2. Remove anonymous users: ${GREEN}Yes${NC}"
echo -e "3. Disallow root login remotely: ${GREEN}Yes${NC}"
echo -e "4. Remove test database: ${GREEN}Yes${NC}"
echo -e "5. Reload privilege tables: ${GREEN}Yes${NC}"
echo -e "${YELLOW}Press Enter to continue...${NC}"
read -r

mysql_secure_installation

echo -e "\n${BLUE}[ACTION REQUIRED] MySQL Root Password${NC}"
echo -e "Please enter your MySQL root password to create the database and user."
echo -e "${YELLOW}Press Enter to continue...${NC}"
read -r

if ! mysql -u root -p <<EOF
CREATE DATABASE IF NOT EXISTS touchgrass;
CREATE USER IF NOT EXISTS 'touchgrass'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON touchgrass.* TO 'touchgrass'@'localhost';
FLUSH PRIVILEGES;
EOF
then
    echo -e "${RED}Error: Failed to set up MySQL database${NC}"
    exit 1
fi

cat > server/src/main/resources/application.properties << EOL
spring.application.name=touchgrass-server
server.port=8080

# Database Configuration
spring.datasource.url=jdbc:mysql://localhost:3306/touchgrass?createDatabaseIfNotExist=true&allowPublicKeyRetrieval=true&useSSL=false
spring.datasource.username=touchgrass
spring.datasource.password=\${MYSQL_PASSWORD:touchgrass}
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

# JPA Configuration
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQL8Dialect
EOL

mkdir -p app server

cat > app/.env << EOL
API_BASE_URL=http://localhost:8080
EOL

cat > server/.env << EOL
MYSQL_PASSWORD=${MYSQL_PASSWORD}
EOL

echo ".env" >> app/.gitignore
echo ".env" >> server/.gitignore

cd app && flutter pub get && cd ..
cd server && ./mvnw clean install && cd ..

echo -e "\n${GREEN}Setup complete!${NC}"
echo -e "\n${BLUE}[NEXT STEPS]${NC}"
echo "1. Start the backend: cd server && ./mvnw spring-boot:run"
echo "2. Start the frontend: cd app && flutter run -d chrome"
echo -e "\n${YELLOW}Note: For mobile devices, update API_BASE_URL in app/.env to your computer's IP${NC}" 