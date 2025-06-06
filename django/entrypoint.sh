#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
python <<END
import socket
import time
import os

host = os.environ.get("DB_HOST", "postgres")
port = 5432
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

while True:
    try:
        s.connect((host, port))
        s.close()
        break
    except socket.error:
        print("PostgreSQL is unavailable - sleeping")
        time.sleep(1)

print("PostgreSQL is up - continuing...")
END

# Apply database migrations
echo "Applying database migrations..."
python manage.py migrate --noinput

# Create superuser if specified in environment
if [ -n "$DJANGO_SUPERUSER_USERNAME" ] && [ -n "$DJANGO_SUPERUSER_PASSWORD" ] && [ -n "$DJANGO_SUPERUSER_EMAIL" ]; then
    echo "Creating superuser..."
    python manage.py createsuperuser --noinput
fi

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput

echo "Django is ready to go!"

# Execute the command provided as arguments to this script
exec "$@"
