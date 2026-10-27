
# Web + Database with Docker

## Description

This project contains a Python Flask web service and a PostgreSQL database.
The application provides a REST API endpoint that returns users stored in the database.

## Technologies

- Python
- Flask
- PostgreSQL
- Docker
- Docker Compose

## Project structure

- app.py - Flask application and /users endpoint
- requirements.txt - Python dependencies
- Dockerfile - Web service image configuration
- docker-compose.yml - Web and database services
- .env.example - Example environment variables

## How to run

1. Install Docker Desktop.
2. Copy .env.example to .env.
3. Open a terminal in the project directory.
4. Run:

   docker compose up --build -d

5. Open http://localhost:5000/users

## API endpoint

GET /users

Returns a JSON list of users stored in PostgreSQL.

## Database persistence

PostgreSQL data is stored in the named Docker volume
postgres_data.

## Stop the application

Run:

docker compose down
