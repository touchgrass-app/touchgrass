# TouchGrass

A habit tracking app that helps you stay connected with nature.

## Prerequisites

Before running the setup script, you need:
1. **Homebrew** - Install it by running:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
2. **Xcode** - Install from the App Store
3. **Command Line Tools** - Run:
   ```bash
   xcode-select --install
   ```

## Quick Start

```bash
# Clone the repository
git clone https://github.com/touchgrass-app/touchgrass.git
cd touchgrass

# Make setup script executable
chmod +x setup.sh

# Run setup
./setup.sh
```

The setup script will:
- Install remaining dependencies (Java, Flutter, MySQL)
- Configure MySQL database
- Set up environment variables
- Build both frontend and backend

## Running the App

After setup completes:

1. Start the backend:
```bash
cd server && ./mvnw spring-boot:run
```

2. Start the frontend:
```bash
cd app && flutter run -d chrome
```

For mobile devices, update `API_BASE_URL` in `app/.env` to your computer's IP address.

## Development

- Backend: Spring Boot (Java)
- Frontend: Flutter
- Database: MySQL

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License
This project is licensed under the MIT License - see the LICENSE file for details.