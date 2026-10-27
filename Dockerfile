
import os
import time

import psycopg2
from flask import Flask, jsonify
from psycopg2.extras import RealDictCursor

app = Flask(__name__)

DB_HOST = os.getenv("DB_HOST", "db")
DB_PORT = int(os.getenv("DB_PORT", "5432"))
DB_NAME = os.getenv("DB_NAME", "usersdb")
DB_USER = os.getenv("DB_USER", "appuser")
DB_PASSWORD = os.getenv("DB_PASSWORD", "apppassword")


def get_connection():
    return psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        connect_timeout=5
    )


def initialize_database():
    # Wait for PostgreSQL to become available.
    for attempt in range(30):
        try:
            with get_connection() as connection:
                with connection.cursor() as cursor:
                    cursor.execute("""
                        CREATE TABLE IF NOT EXISTS users (
                            id SERIAL PRIMARY KEY,
                            name VARCHAR(100) NOT NULL,
                            email VARCHAR(150) UNIQUE NOT NULL
                        )
                    """)

                    cursor.execute("""
                        INSERT INTO users (name, email)
                        VALUES
                            ('John Smith', 'john@example.com'),
                            ('Anna Brown', 'anna@example.com'),
                            ('Michael Green', 'michael@example.com')
                        ON CONFLICT (email) DO NOTHING
                    """)

            print("Database initialized successfully.")
            return

        except psycopg2.OperationalError:
            print(f"Waiting for database... ({attempt + 1}/30)")
            time.sleep(2)

    raise RuntimeError("Could not connect to the database.")


@app.route("/")
def home():
    return jsonify({
        "message": "Web + Database API is running",
        "endpoints": ["/", "/users"]
    })


@app.route("/users", methods=["GET"])
def get_users():
    try:
        with get_connection() as connection:
            with connection.cursor(
                cursor_factory=RealDictCursor
            ) as cursor:
                cursor.execute(
                    "SELECT id, name, email FROM users ORDER BY id"
                )
                users = cursor.fetchall()

        return jsonify(users), 200

    except psycopg2.Error:
        app.logger.exception("Could not retrieve users")
        return jsonify({"error": "Database error"}), 500


if __name__ == "__main__":
    initialize_database()
    app.run(host="0.0.0.0", port=5000)
