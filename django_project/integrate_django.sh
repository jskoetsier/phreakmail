#!/bin/bash

# PhreakMail Django Integration Script
# This script integrates the Django web interface with your existing PhreakMail installation

set -e

# Check if running from the django_project directory
if [ ! -f "manage.py" ]; then
    echo "Error: This script must be run from the django_project directory"
    echo "Please run: cd django_project && ./integrate_django.sh"
    exit 1
fi

echo "PhreakMail Django Integration Script"
echo "==================================="
echo "This script will integrate the Django web interface with your existing PhreakMail installation."
echo "It will replace the old PHP-based web interface with the new Django-based web interface."
echo ""
echo "Press Enter to continue or Ctrl+C to cancel..."
read

# Create necessary directories
echo "Creating necessary directories..."
mkdir -p phreakmail_web/static/css
mkdir -p phreakmail_web/static/js
mkdir -p phreakmail_web/templates/admin
mkdir -p phreakmail_web/templates/user
mkdir -p phreakmail_web/templates/domainadmin

# Run the setup script to create the Django project structure
echo "Setting up Django project structure..."
chmod +x setup_django_project.sh
./setup_django_project.sh

# Copy the nginx configuration
echo "Copying nginx configuration..."
cp -f ../data/conf/nginx/django.conf ../data/conf/nginx/site.conf

# Create a backup of the docker-compose.yml file
echo "Creating backup of docker-compose.yml..."
cp -f ../docker-compose.yml ../docker-compose.yml.bak

# Add the Django service to the docker-compose.yml file
echo "Adding Django service to docker-compose.yml..."
cat docker-compose.django.yml >> ../docker-compose.override.yml

# Create a Dockerfile if it doesn't exist
if [ ! -f "Dockerfile" ]; then
    echo "Creating Dockerfile..."
    cat > Dockerfile << 'EOF'
FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . .

# Expose port
EXPOSE 8000

# Run the application
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "phreakmail.wsgi:application"]
EOF
fi

echo ""
echo "Integration complete!"
echo ""
echo "Next steps:"
echo "1. Add the django-static volume to the volumes section in docker-compose.yml:"
echo "   volumes:"
echo "     django-static:"
echo ""
echo "2. Restart PhreakMail with the new configuration:"
echo "   cd .."
echo "   docker-compose down"
echo "   docker-compose up -d"
echo ""
echo "3. Access the new Django web interface at:"
echo "   https://your-phreakmail-hostname/"
echo ""
echo "Note: If you encounter any issues, you can restore the backup of docker-compose.yml:"
echo "   cp docker-compose.yml.bak docker-compose.yml"
echo ""
