#!/bin/bash
# PhreakMail Migration Script
# This script helps migrate data from a mailcow installation to PhreakMail
# Usage: ./migrate-from-mailcow.sh /path/to/mailcow/backup

# Set colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if a path was provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: No mailcow backup path provided${NC}"
    echo "Usage: $0 /path/to/mailcow/backup"
    exit 1
fi

MAILCOW_BACKUP="$1"
PHREAKMAIL_ROOT=$(cd "$(dirname "$0")/.." && pwd)
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
TEMP_DIR="/tmp/phreakmail-migration-${TIMESTAMP}"

# Function to display script usage
usage() {
    echo -e "${YELLOW}PhreakMail Migration Tool${NC}"
    echo ""
    echo "This script migrates data from a mailcow installation to PhreakMail."
    echo ""
    echo "Usage:"
    echo "  $0 /path/to/mailcow/backup"
    echo ""
    echo "The backup should contain the following directories:"
    echo "  - vmail (email data)"
    echo "  - mysql (database dumps)"
    echo "  - redis (redis dumps)"
    echo "  - config (configuration files)"
    echo ""
    exit 1
}

# Function to check dependencies
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
    if [ ! -f "${PHREAKMAIL_ROOT}/docker-compose.yml" ]; then
        echo -e "${RED}Error: docker-compose.yml not found in ${PHREAKMAIL_ROOT}${NC}"
        echo "Please run this script from the PhreakMail directory or its subdirectories"
        exit 1
    fi

    # Check if PhreakMail is installed and configured
    if [ ! -f "${PHREAKMAIL_ROOT}/phreakmail.conf" ]; then
        echo -e "${RED}Error: phreakmail.conf not found${NC}"
        echo "Please run generate_config.sh first to configure PhreakMail"
        exit 1
    fi

    # Source the configuration file
    source "${PHREAKMAIL_ROOT}/phreakmail.conf"
}

# Function to validate mailcow backup
validate_backup() {
    echo -e "${BLUE}Validating mailcow backup...${NC}"

    # Check if the backup directory exists
    if [ ! -d "${MAILCOW_BACKUP}" ]; then
        echo -e "${RED}Error: Backup directory ${MAILCOW_BACKUP} does not exist${NC}"
        exit 1
    fi

    # Check for essential directories
    local missing_dirs=()

    if [ ! -d "${MAILCOW_BACKUP}/vmail" ] && [ ! -d "${MAILCOW_BACKUP}/data/vmail" ]; then
        missing_dirs+=("vmail (email data)")
    fi

    if [ ! -d "${MAILCOW_BACKUP}/mysql" ] && [ ! -d "${MAILCOW_BACKUP}/database" ]; then
        missing_dirs+=("mysql/database (database dumps)")
    fi

    if [ ! -d "${MAILCOW_BACKUP}/redis" ] && [ ! -d "${MAILCOW_BACKUP}/keydb" ]; then
        missing_dirs+=("redis/keydb (key-value store dumps)")
    fi

    if [ ! -d "${MAILCOW_BACKUP}/config" ] && [ ! -d "${MAILCOW_BACKUP}/conf" ]; then
        missing_dirs+=("config/conf (configuration files)")
    fi

    if [ ${#missing_dirs[@]} -gt 0 ]; then
        echo -e "${RED}Error: The following essential directories are missing from the backup:${NC}"
        for dir in "${missing_dirs[@]}"; do
            echo -e "  - ${dir}"
        done
        echo ""
        echo -e "${YELLOW}Please ensure you have a complete mailcow backup.${NC}"
        exit 1
    fi

    echo -e "  ${GREEN}✓${NC} Backup validation passed"
}

# Function to prepare temporary directory
prepare_temp_dir() {
    echo -e "${BLUE}Preparing temporary directory...${NC}"

    # Create temporary directory
    mkdir -p "${TEMP_DIR}"

    # Create subdirectories
    mkdir -p "${TEMP_DIR}/vmail"
    mkdir -p "${TEMP_DIR}/database"
    mkdir -p "${TEMP_DIR}/keydb"
    mkdir -p "${TEMP_DIR}/config"

    echo -e "  ${GREEN}✓${NC} Temporary directory created: ${TEMP_DIR}"
}

# Function to extract and normalize backup data
extract_backup() {
    echo -e "${BLUE}Extracting backup data...${NC}"

    # Extract vmail data
    if [ -d "${MAILCOW_BACKUP}/vmail" ]; then
        cp -r "${MAILCOW_BACKUP}/vmail" "${TEMP_DIR}/"
        echo -e "  ${GREEN}✓${NC} Email data extracted"
    elif [ -d "${MAILCOW_BACKUP}/data/vmail" ]; then
        cp -r "${MAILCOW_BACKUP}/data/vmail" "${TEMP_DIR}/"
        echo -e "  ${GREEN}✓${NC} Email data extracted"
    else
        echo -e "  ${RED}✗${NC} Could not find email data"
    fi

    # Extract database dumps
    if [ -d "${MAILCOW_BACKUP}/mysql" ]; then
        cp -r "${MAILCOW_BACKUP}/mysql"/* "${TEMP_DIR}/database/"
        echo -e "  ${GREEN}✓${NC} Database dumps extracted"
    elif [ -d "${MAILCOW_BACKUP}/database" ]; then
        cp -r "${MAILCOW_BACKUP}/database"/* "${TEMP_DIR}/database/"
        echo -e "  ${GREEN}✓${NC} Database dumps extracted"
    else
        echo -e "  ${RED}✗${NC} Could not find database dumps"
    fi

    # Extract redis/keydb dumps
    if [ -d "${MAILCOW_BACKUP}/redis" ]; then
        cp -r "${MAILCOW_BACKUP}/redis"/* "${TEMP_DIR}/keydb/"
        echo -e "  ${GREEN}✓${NC} Redis dumps extracted"
    elif [ -d "${MAILCOW_BACKUP}/keydb" ]; then
        cp -r "${MAILCOW_BACKUP}/keydb"/* "${TEMP_DIR}/keydb/"
        echo -e "  ${GREEN}✓${NC} KeyDB dumps extracted"
    else
        echo -e "  ${RED}✗${NC} Could not find Redis/KeyDB dumps"
    fi

    # Extract configuration files
    if [ -d "${MAILCOW_BACKUP}/config" ]; then
        cp -r "${MAILCOW_BACKUP}/config"/* "${TEMP_DIR}/config/"
        echo -e "  ${GREEN}✓${NC} Configuration files extracted"
    elif [ -d "${MAILCOW_BACKUP}/conf" ]; then
        cp -r "${MAILCOW_BACKUP}/conf"/* "${TEMP_DIR}/config/"
        echo -e "  ${GREEN}✓${NC} Configuration files extracted"
    else
        echo -e "  ${RED}✗${NC} Could not find configuration files"
    fi
}

# Function to stop PhreakMail containers
stop_containers() {
    echo -e "${BLUE}Stopping PhreakMail containers...${NC}"

    cd "${PHREAKMAIL_ROOT}" && docker-compose down

    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} PhreakMail containers stopped"
    else
        echo -e "  ${RED}✗${NC} Failed to stop PhreakMail containers"
        exit 1
    fi
}

# Function to migrate database
migrate_database() {
    echo -e "${BLUE}Migrating database...${NC}"

    # Find the most recent SQL dump
    local sql_dump=$(find "${TEMP_DIR}/database" -name "*.sql" -type f -print0 | xargs -0 ls -t | head -1)

    if [ -z "${sql_dump}" ]; then
        echo -e "  ${RED}✗${NC} No SQL dump found in the backup"
        exit 1
    fi

    echo -e "  ${YELLOW}Using SQL dump: ${sql_dump}${NC}"

    # Start MySQL container temporarily
    echo -e "  ${YELLOW}Starting MySQL container...${NC}"
    cd "${PHREAKMAIL_ROOT}" && docker-compose up -d mysql-phreakmail

    # Wait for MySQL to be ready
    echo -e "  ${YELLOW}Waiting for MySQL to be ready...${NC}"
    sleep 10

    # Import the SQL dump
    echo -e "  ${YELLOW}Importing SQL dump...${NC}"
    cat "${sql_dump}" | docker-compose exec -T mysql-phreakmail mysql -u"${DBUSER}" -p"${DBPASS}" "${DBNAME}"

    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} Database imported successfully"
    else
        echo -e "  ${RED}✗${NC} Failed to import database"
        exit 1
    fi

    # Apply schema migrations for PhreakMail
    echo -e "  ${YELLOW}Applying schema migrations...${NC}"
    docker-compose exec -T mysql-phreakmail mysql -u"${DBUSER}" -p"${DBPASS}" "${DBNAME}" < "${PHREAKMAIL_ROOT}/helper-scripts/sql/schema_migrations.sql"

    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} Schema migrations applied successfully"
    else
        echo -e "  ${RED}✗${NC} Failed to apply schema migrations"
        exit 1
    fi
}

# Function to migrate email data
migrate_email_data() {
    echo -e "${BLUE}Migrating email data...${NC}"

    # Check if vmail directory exists in the backup
    if [ ! -d "${TEMP_DIR}/vmail" ]; then
        echo -e "  ${RED}✗${NC} No email data found in the backup"
        return 1
    fi

    # Stop containers if they're running
    cd "${PHREAKMAIL_ROOT}" && docker-compose down

    # Backup existing vmail directory if it exists
    if [ -d "${PHREAKMAIL_ROOT}/data/vmail" ]; then
        echo -e "  ${YELLOW}Backing up existing email data...${NC}"
        mv "${PHREAKMAIL_ROOT}/data/vmail" "${PHREAKMAIL_ROOT}/data/vmail.bak.${TIMESTAMP}"
        echo -e "  ${GREEN}✓${NC} Existing email data backed up"
    fi

    # Create vmail directory if it doesn't exist
    mkdir -p "${PHREAKMAIL_ROOT}/data/vmail"

    # Copy email data
    echo -e "  ${YELLOW}Copying email data (this may take a while)...${NC}"
    cp -r "${TEMP_DIR}/vmail"/* "${PHREAKMAIL_ROOT}/data/vmail/"

    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} Email data migrated successfully"
    else
        echo -e "  ${RED}✗${NC} Failed to migrate email data"
        return 1
    fi

    # Fix permissions
    echo -e "  ${YELLOW}Fixing permissions...${NC}"
    chown -R 5000:5000 "${PHREAKMAIL_ROOT}/data/vmail"

    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} Permissions fixed"
    else
        echo -e "  ${RED}✗${NC} Failed to fix permissions"
        return 1
    fi
}

# Function to migrate KeyDB/Redis data
migrate_keydb_data() {
    echo -e "${BLUE}Migrating KeyDB data...${NC}"

    # Check if keydb directory exists in the backup
    if [ ! -d "${TEMP_DIR}/keydb" ]; then
        echo -e "  ${RED}✗${NC} No KeyDB/Redis data found in the backup"
        return 1
    fi

    # Backup existing keydb directory if it exists
    if [ -d "${PHREAKMAIL_ROOT}/data/keydb" ]; then
        echo -e "  ${YELLOW}Backing up existing KeyDB data...${NC}"
        mv "${PHREAKMAIL_ROOT}/data/keydb" "${PHREAKMAIL_ROOT}/data/keydb.bak.${TIMESTAMP}"
        echo -e "  ${GREEN}✓${NC} Existing KeyDB data backed up"
    fi

    # Create keydb directory if it doesn't exist
    mkdir -p "${PHREAKMAIL_ROOT}/data/keydb"

    # Copy keydb data
    echo -e "  ${YELLOW}Copying KeyDB data...${NC}"
    cp -r "${TEMP_DIR}/keydb"/* "${PHREAKMAIL_ROOT}/data/keydb/"

    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} KeyDB data migrated successfully"
    else
        echo -e "  ${RED}✗${NC} Failed to migrate KeyDB data"
        return 1
    fi

    # Fix permissions
    echo -e "  ${YELLOW}Fixing permissions...${NC}"
    chown -R 999:999 "${PHREAKMAIL_ROOT}/data/keydb"

    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} Permissions fixed"
    else
        echo -e "  ${RED}✗${NC} Failed to fix permissions"
        return 1
    fi
}

# Function to migrate configuration files
migrate_config() {
    echo -e "${BLUE}Migrating configuration files...${NC}"

    # Check if config directory exists in the backup
    if [ ! -d "${TEMP_DIR}/config" ]; then
        echo -e "  ${RED}✗${NC} No configuration files found in the backup"
        return 1
    fi

    # Extract domain and user information from the backup
    echo -e "  ${YELLOW}Extracting domain and user information...${NC}"

    # Create a temporary SQL file to extract domain and user information
    cat > "${TEMP_DIR}/extract_info.sql" << EOF
SELECT domain FROM domain;
SELECT username, domain FROM mailbox;
EOF

    # Execute the SQL file
    docker-compose exec -T mysql-phreakmail mysql -u"${DBUSER}" -p"${DBPASS}" "${DBNAME}" < "${TEMP_DIR}/extract_info.sql" > "${TEMP_DIR}/domain_user_info.txt"

    echo -e "  ${GREEN}✓${NC} Domain and user information extracted"

    # Update PhreakMail configuration
    echo -e "  ${YELLOW}Updating PhreakMail configuration...${NC}"

    # Extract domains from the info file
    domains=$(grep -A 100 "domain" "${TEMP_DIR}/domain_user_info.txt" | grep -v "domain" | grep -v "^$" | grep -v "rows in set" | tr -d " \t\r" | paste -sd "," -)

    # Update ADDITIONAL_SERVER_NAMES in phreakmail.conf
    if [ -n "$domains" ]; then
        sed -i.bak "s/^ADDITIONAL_SERVER_NAMES=.*/ADDITIONAL_SERVER_NAMES=${domains}/" "${PHREAKMAIL_ROOT}/phreakmail.conf"
        echo -e "  ${GREEN}✓${NC} Updated ADDITIONAL_SERVER_NAMES in phreakmail.conf"
    fi

    echo -e "  ${GREEN}✓${NC} Configuration updated"
}

# Function to start PhreakMail containers
start_containers() {
    echo -e "${BLUE}Starting PhreakMail containers...${NC}"

    cd "${PHREAKMAIL_ROOT}" && docker-compose up -d

    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} PhreakMail containers started"
    else
        echo -e "  ${RED}✗${NC} Failed to start PhreakMail containers"
        exit 1
    fi
}

# Function to clean up temporary files
cleanup() {
    echo -e "${BLUE}Cleaning up temporary files...${NC}"

    rm -rf "${TEMP_DIR}"

    echo -e "  ${GREEN}✓${NC} Temporary files cleaned up"
}

# Main script execution
check_dependencies
validate_backup
prepare_temp_dir
extract_backup
stop_containers
migrate_database
migrate_email_data
migrate_keydb_data
migrate_config
start_containers
cleanup

echo ""
echo -e "${GREEN}Migration completed successfully!${NC}"
echo -e "Your mailcow data has been migrated to PhreakMail."
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Verify that all your domains and email accounts are working correctly"
echo "2. Update your DNS records if necessary"
echo "3. Test sending and receiving emails"
echo "4. Access the webmail interface at https://${PHREAKMAIL_HOSTNAME}/webmail"
echo "5. Access the admin interface at https://${PHREAKMAIL_HOSTNAME}/admin"
echo ""
echo -e "${YELLOW}Note:${NC} If you encounter any issues, please check the container logs:"
echo "docker-compose logs"
echo ""
