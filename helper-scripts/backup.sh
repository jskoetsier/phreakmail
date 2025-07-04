#!/bin/bash
# PhreakMail Backup Script
# This script creates a complete backup of PhreakMail data
# Usage: ./backup.sh [destination_directory]

# Set colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default backup directory (current directory if not specified)
BACKUP_DIR="${1:-$(pwd)/phreakmail-backup-$(date +%Y%m%d-%H%M%S)}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
PHREAKMAIL_ROOT=$(cd "$(dirname "$0")/.." && pwd)

# Function to display script usage
usage() {
    echo -e "${YELLOW}PhreakMail Backup Tool${NC}"
    echo ""
    echo "This script creates a complete backup of your PhreakMail installation."
    echo ""
    echo "Usage:"
    echo "  $0 [destination_directory]"
    echo ""
    echo "If no destination directory is provided, the backup will be created in the current directory."
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

    # Check if we're in the PhreakMail directory or a subdirectory
    if [ ! -f "${PHREAKMAIL_ROOT}/docker-compose.yml" ]; then
        echo -e "${RED}Error: docker-compose.yml not found in ${PHREAKMAIL_ROOT}${NC}"
        echo "Please run this script from the PhreakMail directory or its subdirectories"
        exit 1
    fi
}

# Function to create backup directory
create_backup_dir() {
    echo -e "${BLUE}Creating backup directory: ${BACKUP_DIR}${NC}"
    mkdir -p "${BACKUP_DIR}"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Failed to create backup directory${NC}"
        exit 1
    fi
}

# Function to backup configuration files
backup_config() {
    echo -e "${BLUE}Backing up configuration files...${NC}"

    # Create config directory
    mkdir -p "${BACKUP_DIR}/config"

    # Backup main configuration file
    if [ -f "${PHREAKMAIL_ROOT}/phreakmail.conf" ]; then
        cp "${PHREAKMAIL_ROOT}/phreakmail.conf" "${BACKUP_DIR}/config/"
        echo -e "  ${GREEN}✓${NC} phreakmail.conf"
    else
        echo -e "  ${RED}✗${NC} phreakmail.conf not found"
    fi

    # Backup docker-compose files
    if [ -f "${PHREAKMAIL_ROOT}/docker-compose.yml" ]; then
        cp "${PHREAKMAIL_ROOT}/docker-compose.yml" "${BACKUP_DIR}/config/"
        echo -e "  ${GREEN}✓${NC} docker-compose.yml"
    fi

    if [ -f "${PHREAKMAIL_ROOT}/docker-compose.override.yml" ]; then
        cp "${PHREAKMAIL_ROOT}/docker-compose.override.yml" "${BACKUP_DIR}/config/"
        echo -e "  ${GREEN}✓${NC} docker-compose.override.yml"
    fi

    # Backup configuration directories
    if [ -d "${PHREAKMAIL_ROOT}/data/conf" ]; then
        cp -r "${PHREAKMAIL_ROOT}/data/conf" "${BACKUP_DIR}/config/"
        echo -e "  ${GREEN}✓${NC} Configuration directories"
    else
        echo -e "  ${RED}✗${NC} Configuration directories not found"
    fi
}

# Function to backup database
backup_database() {
    echo -e "${BLUE}Backing up database...${NC}"

    # Source the configuration file to get database credentials
    if [ -f "${PHREAKMAIL_ROOT}/phreakmail.conf" ]; then
        source "${PHREAKMAIL_ROOT}/phreakmail.conf"
    else
        echo -e "  ${RED}✗${NC} phreakmail.conf not found, cannot backup database"
        return 1
    fi

    # Create database backup directory
    mkdir -p "${BACKUP_DIR}/database"

    # Check if MySQL container is running
    if ! docker-compose -f "${PHREAKMAIL_ROOT}/docker-compose.yml" ps | grep -q "mysql-phreakmail.*Up"; then
        echo -e "  ${RED}✗${NC} MySQL container is not running, cannot backup database"
        return 1
    fi

    # Backup database
    echo -e "  ${YELLOW}Dumping database ${DBNAME}...${NC}"
    docker-compose -f "${PHREAKMAIL_ROOT}/docker-compose.yml" exec -T mysql-phreakmail mysqldump -u"${DBUSER}" -p"${DBPASS}" --single-transaction --routines --triggers --events "${DBNAME}" > "${BACKUP_DIR}/database/${DBNAME}-${TIMESTAMP}.sql"

    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} Database backup completed"
    else
        echo -e "  ${RED}✗${NC} Database backup failed"
        return 1
    fi
}

# Function to backup email data
backup_email_data() {
    echo -e "${BLUE}Backing up email data...${NC}"

    # Create email data backup directory
    mkdir -p "${BACKUP_DIR}/vmail"

    # Check if vmail directory exists
    if [ -d "${PHREAKMAIL_ROOT}/data/vmail" ]; then
        echo -e "  ${YELLOW}Copying email data (this may take a while)...${NC}"
        cp -r "${PHREAKMAIL_ROOT}/data/vmail" "${BACKUP_DIR}/"
        if [ $? -eq 0 ]; then
            echo -e "  ${GREEN}✓${NC} Email data backup completed"
        else
            echo -e "  ${RED}✗${NC} Email data backup failed"
            return 1
        fi
    else
        echo -e "  ${RED}✗${NC} Email data directory not found"
        return 1
    fi
}

# Function to backup Redis/KeyDB data
backup_keydb_data() {
    echo -e "${BLUE}Backing up KeyDB data...${NC}"

    # Create KeyDB backup directory
    mkdir -p "${BACKUP_DIR}/keydb"

    # Check if KeyDB container is running
    if ! docker-compose -f "${PHREAKMAIL_ROOT}/docker-compose.yml" ps | grep -q "keydb-phreakmail.*Up"; then
        echo -e "  ${RED}✗${NC} KeyDB container is not running, cannot backup data"
        return 1
    fi

    # Backup KeyDB data
    echo -e "  ${YELLOW}Creating KeyDB snapshot...${NC}"
    docker-compose -f "${PHREAKMAIL_ROOT}/docker-compose.yml" exec -T keydb-phreakmail keydb-cli save

    # Copy dump.rdb file
    if [ -f "${PHREAKMAIL_ROOT}/data/keydb/dump.rdb" ]; then
        cp "${PHREAKMAIL_ROOT}/data/keydb/dump.rdb" "${BACKUP_DIR}/keydb/dump.rdb-${TIMESTAMP}"
        echo -e "  ${GREEN}✓${NC} KeyDB data backup completed"
    else
        echo -e "  ${RED}✗${NC} KeyDB dump file not found"
        return 1
    fi
}

# Function to backup SSL certificates
backup_ssl_certs() {
    echo -e "${BLUE}Backing up SSL certificates...${NC}"

    # Create SSL backup directory
    mkdir -p "${BACKUP_DIR}/ssl"

    # Check if SSL directory exists
    if [ -d "${PHREAKMAIL_ROOT}/data/assets/ssl" ]; then
        cp -r "${PHREAKMAIL_ROOT}/data/assets/ssl" "${BACKUP_DIR}/"
        echo -e "  ${GREEN}✓${NC} SSL certificates backup completed"
    else
        echo -e "  ${RED}✗${NC} SSL certificates directory not found"
        return 1
    fi
}

# Function to create compressed archive
create_archive() {
    echo -e "${BLUE}Creating compressed archive...${NC}"

    # Create tar.gz archive
    ARCHIVE_NAME="phreakmail-backup-${TIMESTAMP}.tar.gz"
    tar -czf "${PHREAKMAIL_ROOT}/${ARCHIVE_NAME}" -C "$(dirname "${BACKUP_DIR}")" "$(basename "${BACKUP_DIR}")"

    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} Archive created: ${PHREAKMAIL_ROOT}/${ARCHIVE_NAME}"

        # Remove temporary backup directory
        rm -rf "${BACKUP_DIR}"

        # Update backup dir to archive path
        BACKUP_DIR="${PHREAKMAIL_ROOT}/${ARCHIVE_NAME}"
    else
        echo -e "  ${RED}✗${NC} Failed to create archive"
        return 1
    fi
}

# Main script execution starts here
check_dependencies
create_backup_dir

# Perform backups
backup_config
backup_database
backup_email_data
backup_keydb_data
backup_ssl_certs

# Create compressed archive
create_archive

echo ""
echo -e "${GREEN}Backup completed successfully!${NC}"
echo -e "Backup location: ${YELLOW}${BACKUP_DIR}${NC}"
echo ""
echo -e "${YELLOW}To restore this backup:${NC}"
echo "1. Extract the archive (if compressed)"
echo "2. Copy configuration files back to their original locations"
echo "3. Restore the database using the SQL dump"
echo "4. Copy email data back to the vmail directory"
echo "5. Restart PhreakMail containers"
echo ""
