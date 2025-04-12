# TouchGrass

A habit tracking app that helps you stay connected with nature.

## Prerequisites

Before running the application, you need:
1. **Docker Desktop** - Install it from [Docker's website](https://www.docker.com/products/docker-desktop/). Docker Desktop is available for macOS, Windows, and Linux.
2. **Flutter** - Install it from [Flutter's website](https://flutter.dev/docs/get-started/install).
3. **VSCode** - Install it from [VSCode's website](https://code.visualstudio.com/).
4. **Git** - Install it from [Git's website](https://git-scm.com/downloads).

##
If you are on macOS or Linux, use the "Quick Start" section. If you are on Windows, use the "Quick Start (PowerShell)" section.

## Quick Start

```bash
# Clone the repository
git clone https://github.com/touchgrass-app/touchgrass.git
cd touchgrass

# Set up the .env files
cp server/.env.template server/.env
cp app/.env.template app/.env

# Add the following environment variables to the .env file:
# MYSQL_USER: The username for the MySQL database.
# MYSQL_PASSWORD: The password for the MySQL database.
# MYSQL_DATABASE: The name of the MySQL database.
# MYSQL_HOST: The host address of the MySQL database.
# MYSQL_PORT: The port number of the MySQL database.
# SERVER_PORT: The port number for the backend server.
# JWT_SECRET: The secret key used for JWT authentication.

# Build the backend using Docker Compose
cd server && docker compose up --build

# Start the frontend (in a new terminal)
cd app && flutter run -d chrome
```

## Quick Start (PowerShell)

```powershell
# Clone the repository
git clone https://github.com/touchgrass-app/touchgrass.git
cd touchgrass

# Set up the .env files
copy server\.env.template server\.env
copy app\.env.template app\.env

# Add the following environment variables to the .env file:
# MYSQL_USER: The username for the MySQL database.
# MYSQL_PASSWORD: The password for the MySQL database.
# MYSQL_DATABASE: The name of the MySQL database.
# MYSQL_HOST: The host address of the MySQL database.
# MYSQL_PORT: The port number of the MySQL database.
# SERVER_PORT: The port number for the backend server.
# JWT_SECRET: The secret key used for JWT authentication.

# Build the backend using Docker Compose
cd server ; docker compose up --build

# Start the frontend (in a new terminal)
cd app ; flutter run -d chrome
```

The Docker Compose setup will:
- Build the backend Docker image
- Start the backend service
- Configure the MySQL database. Ensure the database is running before starting the frontend.

## Running the App

After building the backend with Docker Compose and starting the frontend with Flutter:

The application should be accessible in your web browser.

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
