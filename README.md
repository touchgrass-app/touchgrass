# TouchGrass

A habit-tracking app inspired by BeReal, built with Flutter and Spring Boot.

## Prerequisites

### Development Environment
- macOS (for iOS development)
- Git
- Homebrew (macOS package manager)

### Backend Requirements
- Java 17 or later
- MySQL 8.0 or later
- Maven (included with the project)

### Frontend Requirements
- Flutter SDK
- Xcode (for iOS development)
- Android Studio (for Android development)

## Installation Guide

### 1. Install Development Tools

```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Java
brew install openjdk@17

# Install Flutter
brew install flutter

# Install MySQL
brew install mysql

# Install Xcode from the App Store
# After installation, run:
xcode-select --install
```

### 2. Set Up MySQL

```bash
# Start MySQL service
brew services start mysql

# Secure MySQL installation
mysql_secure_installation
# Follow the prompts and set a root password
# Remember the password you set - you'll need it for the application.properties file
```

### 3. Clone the Repository

```bash
git clone https://github.com/yourusername/touchgrass.git
cd touchgrass
```

### 4. Configure Backend

1. Navigate to the server directory:
```bash
cd server
```

2. Update the database configuration in `src/main/resources/application.properties`:
```properties
spring.datasource.url=jdbc:mysql://localhost:3306/touchgrass?createDatabaseIfNotExist=true&allowPublicKeyRetrieval=true&useSSL=false
spring.datasource.username=root
spring.datasource.password=your_mysql_password
```

3. Build and run the server:
```bash
./mvnw spring-boot:run
```

### 5. Configure Frontend

1. Navigate to the app directory:
```bash
cd app
```

2. Create a `.env` file:
```bash
cp .env.example .env
```

3. Update the `.env` file with your backend URL:
```properties
API_BASE_URL=http://localhost:8080
```

4. Install Flutter dependencies:
```bash
flutter pub get
```

## Running the Application

### Backend
```bash
cd server
./mvnw spring-boot:run
```

### Frontend

#### Web
```bash
cd app
flutter run -d chrome
```

#### iOS Simulator
```bash
cd app
flutter run -d ios
```

#### Android Emulator
1. Open Android Studio
2. Create a new Android Virtual Device (AVD)
3. Start the emulator
4. Run the app:
```bash
cd app
flutter run -d android
```

## Project Structure

```
touchgrass/
├── app/                 # Flutter frontend application
│   ├── lib/            # Dart source code
│   ├── assets/         # Static assets
│   └── pubspec.yaml    # Flutter dependencies
│
└── server/             # Spring Boot backend application
    ├── src/            # Java source code
    └── pom.xml         # Maven dependencies
```

## Development

### Backend Development
- The backend uses Spring Boot with a layered architecture
- Main packages:
  - `domain/`: Business logic and entities
  - `application/`: Use cases and application services
  - `infrastructure/`: Database and external service implementations
  - `interfaces/`: REST controllers and DTOs

### Frontend Development
- The frontend uses Flutter with a clean architecture
- Main directories:
  - `lib/screens/`: UI screens
  - `lib/widgets/`: Reusable UI components
  - `lib/services/`: API and business logic
  - `lib/models/`: Data models
  - `lib/config/`: Configuration files

## Testing

### Backend Tests
```bash
cd server
./mvnw test
```

### Frontend Tests
```bash
cd app
flutter test
```

## Troubleshooting

### MySQL Connection Issues
1. Ensure MySQL is running:
```bash
brew services list | grep mysql
```

2. If not running, start it:
```bash
brew services start mysql
```

3. Verify MySQL is accessible:
```bash
mysql -u root -p
```

### Flutter Issues
1. Check Flutter installation:
```bash
flutter doctor
```

2. Update Flutter:
```bash
flutter upgrade
```

3. Clean and rebuild:
```bash
flutter clean
flutter pub get
```

## Contributing
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License
This project is licensed under the MIT License - see the LICENSE file for details.