#!/bin/bash
# PhreakMail Admin Password Reset Script
# This script resets the admin password for the PhreakMail system
# Usage: ./phreakmail-reset-admin.sh [new_password]

# Set colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display script usage
usage() {
    echo -e "${YELLOW}PhreakMail Admin Password Reset Tool${NC}"
    echo ""
    echo "This script resets the admin password for the PhreakMail system."
    echo ""
    echo "Usage:"
    echo "  $0 [new_password]"
    echo ""
    echo "If no password is provided, the script will generate a secure random password."
    echo ""
    exit 1
}

# Function to check if docker and docker-compose are installed
check_dependencies() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Error: Docker is not installed or not in PATH${NC}"
        exit 1
    fi

    if ! docker ps &> /dev/null; then
        echo -e "${RED}Error: Docker daemon is not running or you don't have permission to use it${NC}"
        exit 1
    fi

    # Check if we're in the PhreakMail directory
    if [ ! -f "docker-compose.yml" ]; then
        echo -e "${RED}Error: docker-compose.yml not found${NC}"
        echo "Please run this script from the PhreakMail root directory"
        exit 1
    fi
}

# Function to generate a secure random password
generate_password() {
    # Generate a 16-character password with letters, numbers, and special characters
    password=$(LC_ALL=C tr -dc 'A-Za-z0-9!@#$%^&*()_+' < /dev/urandom | head -c 16)
    echo "$password"
}

# Function to hash password for database storage
hash_password() {
    local password=$1
    # Use the same container to hash the password with PHP's password_hash function
    docker-compose exec -T php-fpm-phreakmail php -r "echo password_hash('$password', PASSWORD_DEFAULT);"
}

# Function to reset the admin password in the database
reset_password() {
    local password=$1
    local hashed_password=$(hash_password "$password")

    if [ -z "$hashed_password" ]; then
        echo -e "${RED}Error: Failed to hash password${NC}"
        exit 1
    fi

    echo -e "${YELLOW}Updating admin password in database...${NC}"

    # Execute SQL command to update the admin password
    docker-compose exec -T mysql-phreakmail mysql -u"${DBUSER}" -p"${DBPASS}" "${DBNAME}" -e "
        UPDATE admin SET password='$hashed_password' WHERE username='admin';
    "

    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Failed to update admin password in database${NC}"
        exit 1
    fi

    echo -e "${GREEN}Admin password has been successfully reset!${NC}"
}

# Main script execution starts here
check_dependencies

# Source the configuration file to get database credentials
if [ -f "phreakmail.conf" ]; then
    source phreakmail.conf
else
    echo -e "${RED}Error: phreakmail.conf not found${NC}"
    echo "Please run this script from the PhreakMail root directory"
    exit 1
fi

# Check if database credentials are available
if [ -z "$DBNAME" ] || [ -z "$DBUSER" ] || [ -z "$DBPASS" ]; then
    echo -e "${RED}Error: Database credentials not found in phreakmail.conf${NC}"
    exit 1
fi

# Check if containers are running
if ! docker-compose ps | grep -q "mysql-phreakmail.*Up.*"; then
    echo -e "${RED}Error: MySQL container is not running${NC}"
    echo "Please start PhreakMail containers with: docker-compose up -d"
    exit 1
fi

if ! docker-compose ps | grep -q "php-fpm-phreakmail.*Up.*"; then
    echo -e "${RED}Error: PHP-FPM container is not running${NC}"
    echo "Please start PhreakMail containers with: docker-compose up -d"
    exit 1
fi

# Get password from command line or generate one
if [ -n "$1" ]; then
    NEW_PASSWORD="$1"
    echo -e "${YELLOW}Using provided password${NC}"
else
    NEW_PASSWORD=$(generate_password)
    echo -e "${YELLOW}Generated random password: ${GREEN}$NEW_PASSWORD${NC}"
    echo -e "${YELLOW}Please save this password in a secure location!${NC}"
fi

# Reset the admin password
reset_password "$NEW_PASSWORD"

echo ""
echo -e "${GREEN}Password reset complete!${NC}"
echo -e "You can now log in to the PhreakMail admin interface at:"
echo -e "${YELLOW}https://${PHREAKMAIL_HOSTNAME}/admin${NC}"
echo -e "Username: ${GREEN}admin${NC}"
echo -e "Password: ${GREEN}$NEW_PASSWORD${NC}"
echo ""
