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

print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

print_step() {
    echo -e "${GREEN}→${NC} $1"
}

check_prerequisites() {
    local missing_deps=()
    
    if ! command_exists brew; then
        missing_deps+=("Homebrew")
    fi
    
    if ! command_exists xcode-select; then
        missing_deps+=("Xcode Command Line Tools")
    fi
    
    if [ ! -d "/Applications/Xcode.app" ]; then
        missing_deps+=("Xcode")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_header "Missing Prerequisites"
        echo -e "${RED}The following dependencies are required:${NC}"
        for dep in "${missing_deps[@]}"; do
            echo -e "  • ${dep}"
        done
        echo -e "\n${BLUE}Installation instructions:${NC}"
        echo -e "1. Homebrew: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        echo -e "2. Xcode: Install from App Store"
        echo -e "3. Command Line Tools: xcode-select --install"
        exit 1
    fi
}

setup_env_files() {
    print_step "Setting up environment files..."
    
    # Create template files if they don't exist
    if [ ! -f "app/.env" ]; then
        cp app/.env.template app/.env
        echo -e "${YELLOW}Created app/.env from template${NC}"
    else
        echo -e "${YELLOW}app/.env already exists, skipping${NC}"
    fi
    
    if [ ! -f "server/.env" ]; then
        cp server/.env.template server/.env
        echo -e "${YELLOW}Created server/.env from template${NC}"
    else
        echo -e "${YELLOW}server/.env already exists, skipping${NC}"
    fi
}

setup_database() {
    print_step "Setting up MySQL..."
    
    if ! command_exists mysql; then
        echo -e "${YELLOW}MySQL not found, installing...${NC}"
        brew install mysql
    fi
    
    # Check if MySQL is running
    if ! mysqladmin ping -u root --silent 2>/dev/null; then
        echo -e "${YELLOW}Starting MySQL...${NC}"
        brew services start mysql
        sleep 5  # Give MySQL time to start
    fi
    
    echo -e "\n${BLUE}[DATABASE SETUP]${NC}"
    echo -e "1. Run: ${YELLOW}mysql_secure_installation${NC} to secure your MySQL installation"
    echo -e "2. Create database and user:"
    echo -e "   ${YELLOW}mysql -u root -p${NC}"
    echo -e "   ${YELLOW}CREATE DATABASE IF NOT EXISTS touchgrass;${NC}"
    echo -e "   ${YELLOW}CREATE USER IF NOT EXISTS 'touchgrass'@'localhost' IDENTIFIED BY 'your_password';${NC}"
    echo -e "   ${YELLOW}GRANT ALL PRIVILEGES ON touchgrass.* TO 'touchgrass'@'localhost';${NC}"
    echo -e "   ${YELLOW}FLUSH PRIVILEGES;${NC}"
    echo -e "3. Update your server/.env with the database credentials"
}

setup_dependencies() {
    print_step "Installing project dependencies..."
    
    if ! command_exists java; then
        echo -e "${YELLOW}Installing Java...${NC}"
        brew install openjdk@17
    fi
    
    if ! command_exists flutter; then
        echo -e "${YELLOW}Installing Flutter...${NC}"
        brew install flutter
    fi
    
    print_step "Installing Flutter dependencies..."
    (cd app && flutter pub get)
    
    print_step "Building Spring Boot application..."
    (cd server && ./mvnw clean install)
}

print_header "TouchGrass Setup Script"
echo -e "This script will help you set up the TouchGrass development environment."
echo -e "It will:"
echo -e "  • Check and install required dependencies"
echo -e "  • Set up environment files"
echo -e "  • Guide you through database setup"
echo -e "  • Install project dependencies"
echo -e "\n${YELLOW}Note: This script will not make any changes to your Git configuration${NC}"
echo -e "${YELLOW}Press Ctrl+C to cancel or Enter to continue...${NC}"
read -r

check_prerequisites
setup_env_files
setup_database
setup_dependencies

print_header "Setup Complete!"
echo -e "${BLUE}[NEXT STEPS]${NC}"
echo -e "1. Configure your environment files:"
echo -e "   • app/.env - Set your API base URL"
echo -e "   • server/.env - Set your database credentials"
echo -e "\n2. Start the backend:"
echo -e "   cd server && ./mvnw spring-boot:run"
echo -e "\n3. Start the frontend:"
echo -e "   cd app && flutter run -d chrome"
echo -e "\n${YELLOW}For more information, see the README.md${NC}" 