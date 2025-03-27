#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check prerequisites
check_prerequisites() {
    echo -e "${YELLOW}Checking prerequisites...${NC}"
    
    # Check for Homebrew
    if ! command_exists brew; then
        echo -e "${RED}Homebrew is not installed.${NC}"
        echo -e "${YELLOW}Please install Homebrew first:${NC}"
        echo -e "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        echo -e "${YELLOW}After installing Homebrew, run this script again.${NC}"
        exit 1
    fi

    # Check for Xcode Command Line Tools
    if ! command_exists xcode-select; then
        echo -e "${RED}Xcode Command Line Tools are not installed.${NC}"
        echo -e "${YELLOW}Please install Xcode Command Line Tools first:${NC}"
        echo -e "  xcode-select --install"
        echo -e "${YELLOW}After installing Xcode Command Line Tools, run this script again.${NC}"
        exit 1
    fi

    # Check for Xcode
    if [ ! -d "/Applications/Xcode.app" ]; then
        echo -e "${RED}Xcode is not installed.${NC}"
        echo -e "${YELLOW}Please install Xcode from the App Store first.${NC}"
        echo -e "${YELLOW}After installing Xcode, run this script again.${NC}"
        exit 1
    fi

    echo -e "${GREEN}All prerequisites are installed!${NC}"
}

# Function to wait for MySQL to be ready
wait_for_mysql() {
    echo -e "${YELLOW}Waiting for MySQL to be ready...${NC}"
    for i in {1..30}; do
        if mysqladmin ping -u root --silent; then
            echo -e "${GREEN}MySQL is ready!${NC}"
            return 0
        fi
        echo -e "${YELLOW}Waiting for MySQL... (attempt $i/30)${NC}"
        sleep 1
    done
    echo -e "${RED}MySQL failed to start within 30 seconds${NC}"
    return 1
}

# Function to check if MySQL is running
check_mysql() {
    if ! command_exists mysql; then
        echo -e "${RED}MySQL is not installed.${NC}"
        echo -e "${YELLOW}Installing MySQL...${NC}"
        brew install mysql
    fi

    # Check if MySQL is running
    if ! mysqladmin ping -u root --silent 2>/dev/null; then
        echo -e "${YELLOW}MySQL is not running. Starting MySQL service...${NC}"
        brew services stop mysql
        brew services start mysql
        wait_for_mysql
    else
        echo -e "${GREEN}MySQL is already running${NC}"
    fi
}

# Main setup process
echo -e "${GREEN}Starting TouchGrass setup...${NC}"

# Check prerequisites first
check_prerequisites

# Install Java if not present
if ! command_exists java; then
    echo -e "${YELLOW}Installing Java...${NC}"
    brew install openjdk@17
else
    echo -e "${GREEN}Java is already installed${NC}"
fi

# Install Flutter if not present
if ! command_exists flutter; then
    echo -e "${YELLOW}Installing Flutter...${NC}"
    brew install flutter
else
    echo -e "${GREEN}Flutter is already installed${NC}"
fi

# Check and setup MySQL
check_mysql

# Secure MySQL installation
echo -e "${YELLOW}Securing MySQL installation...${NC}"
echo -e "${YELLOW}Please follow the prompts to set up MySQL security.${NC}"
echo -e "${YELLOW}Recommended settings:${NC}"
echo -e "1. Set root password: Yes"
echo -e "2. Remove anonymous users: Yes"
echo -e "3. Disallow root login remotely: Yes"
echo -e "4. Remove test database: Yes"
echo -e "5. Reload privilege tables: Yes"
mysql_secure_installation

# Create database and user
echo -e "${YELLOW}Creating database and user...${NC}"
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS touchgrass;"
mysql -u root -p -e "CREATE USER IF NOT EXISTS 'touchgrass'@'localhost' IDENTIFIED BY 'touchgrass';"
mysql -u root -p -e "GRANT ALL PRIVILEGES ON touchgrass.* TO 'touchgrass'@'localhost';"
mysql -u root -p -e "FLUSH PRIVILEGES;"

# Update application.properties
echo -e "${YELLOW}Updating application.properties...${NC}"
cat > server/src/main/resources/application.properties << EOL
spring.application.name=touchgrass-server
server.port=8080

# Database Configuration
spring.datasource.url=jdbc:mysql://localhost:3306/touchgrass?createDatabaseIfNotExist=true&allowPublicKeyRetrieval=true&useSSL=false
spring.datasource.username=touchgrass
spring.datasource.password=touchgrass
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

# JPA Configuration
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQL8Dialect
EOL

# Create .env file for Flutter app
echo -e "${YELLOW}Creating .env file for Flutter app...${NC}"
cat > app/.env << EOL
API_BASE_URL=http://localhost:8080
EOL

# Install Flutter dependencies
echo -e "${YELLOW}Installing Flutter dependencies...${NC}"
cd app
flutter pub get
cd ..

# Build Spring Boot application
echo -e "${YELLOW}Building Spring Boot application...${NC}"
cd server
./mvnw clean install
cd ..

echo -e "${GREEN}Setup completed successfully!${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Start the backend: cd server && ./mvnw spring-boot:run"
echo "2. Start the frontend: cd app && flutter run -d chrome"
echo -e "${YELLOW}Note: If you need to connect from a mobile device, update the API_BASE_URL in app/.env to use your computer's IP address${NC}" 