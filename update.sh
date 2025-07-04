#!/bin/bash
# PhreakMail Update Script
# This script checks for updates from the git repository, makes a backup,
# stops containers, updates, and restarts the containers

# Set colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SCRIPT="${SCRIPT_DIR}/helper-scripts/backup.sh"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_FILE="${SCRIPT_DIR}/update-${TIMESTAMP}.log"
GIT_REPO="https://github.com/jskoetsier/phreakmail"

# Function to log messages
log() {
    local message="$1"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "${timestamp} - ${message}" | tee -a "${LOG_FILE}"
}

# Function to log errors
log_error() {
    local message="$1"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "${RED}${timestamp} - ERROR: ${message}${NC}" | tee -a "${LOG_FILE}"
}

# Function to log success
log_success() {
    local message="$1"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "${GREEN}${timestamp} - SUCCESS: ${message}${NC}" | tee -a "${LOG_FILE}"
}

# Function to log info
log_info() {
    local message="$1"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "${BLUE}${timestamp} - INFO: ${message}${NC}" | tee -a "${LOG_FILE}"
}

# Function to log warning
log_warning() {
    local message="$1"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "${YELLOW}${timestamp} - WARNING: ${message}${NC}" | tee -a "${LOG_FILE}"
}

# Function to check dependencies
check_dependencies() {
    log_info "Checking dependencies..."

    # Check if git is installed
    if ! command -v git &> /dev/null; then
        log_error "Git is not installed. Please install git and try again."
        exit 1
    fi

    # Check if docker is installed
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed. Please install Docker and try again."
        exit 1
    fi

    # Check if docker-compose is installed
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        log_error "Docker Compose is not installed. Please install Docker Compose and try again."
        exit 1
    fi

    log_success "All dependencies are installed."
}

# Function to check if the current directory is a git repository
check_git_repo() {
    log_info "Checking if the current directory is a git repository..."

    if [ ! -d "${SCRIPT_DIR}/.git" ]; then
        log_warning "This directory is not a git repository. Initializing git repository..."

        # Initialize git repository
        git init

        # Add remote repository
        git remote add origin "${GIT_REPO}"

        # Create .gitignore file if it doesn't exist
        if [ ! -f "${SCRIPT_DIR}/.gitignore" ]; then
            cat > "${SCRIPT_DIR}/.gitignore" << EOF
# PhreakMail .gitignore
data/db/
data/vmail/
data/keydb/
data/rspamd/
data/postfix/
data/dovecot/
data/comodo/
data/rainloop/
data/apache2/
data/acme/
data/ssl/
data/sieve/
data/dkim/
data/watchdog/
data/dockerapi/
data/olefy/
data/netfilter/
data/unbound/
data/django/
phreakmail.conf
.env
update-*.log
backup-*.log
EOF
            log_info "Created .gitignore file."
        fi

        log_success "Git repository initialized."
    else
        # Check if the remote repository is set correctly
        local remote_url=$(git config --get remote.origin.url)

        if [ "${remote_url}" != "${GIT_REPO}" ]; then
            log_warning "Remote repository URL is not set correctly. Current URL: ${remote_url}"
            log_warning "Setting remote repository URL to ${GIT_REPO}..."

            git remote set-url origin "${GIT_REPO}"

            log_success "Remote repository URL updated."
        else
            log_success "Git repository is properly configured."
        fi
    fi
}

# Function to check for updates
check_for_updates() {
    log_info "Checking for updates..."

    # Fetch the latest changes
    git fetch origin

    # Check if there are any updates
    local local_commit=$(git rev-parse HEAD)
    local remote_commit=$(git rev-parse origin/main)

    if [ "${local_commit}" = "${remote_commit}" ]; then
        log_info "You are already running the latest version of PhreakMail."
        return 1
    else
        log_info "Updates are available. Current version: ${local_commit:0:7}, Latest version: ${remote_commit:0:7}"

        # Show the changes
        log_info "Changes since your version:"
        git log --oneline --no-decorate "${local_commit}..${remote_commit}" | head -n 10

        # If there are more than 10 commits, show a message
        local commit_count=$(git log --oneline "${local_commit}..${remote_commit}" | wc -l | tr -d ' ')
        if [ "${commit_count}" -gt 10 ]; then
            log_info "... and $(($commit_count - 10)) more commits."
        fi

        return 0
    fi
}

# Function to create a backup
create_backup() {
    log_info "Creating a backup before updating..."

    if [ -f "${BACKUP_SCRIPT}" ]; then
        # Execute the backup script
        bash "${BACKUP_SCRIPT}"

        if [ $? -eq 0 ]; then
            log_success "Backup created successfully."
        else
            log_error "Failed to create backup. Aborting update."
            exit 1
        fi
    else
        log_error "Backup script not found at ${BACKUP_SCRIPT}. Aborting update."
        exit 1
    fi
}

# Function to stop containers
stop_containers() {
    log_info "Stopping containers..."

    cd "${SCRIPT_DIR}" && docker-compose down

    if [ $? -eq 0 ]; then
        log_success "Containers stopped successfully."
    else
        log_error "Failed to stop containers. Aborting update."
        exit 1
    fi
}

# Function to update the repository
update_repository() {
    log_info "Updating repository..."

    # Pull the latest changes
    git pull origin main

    if [ $? -eq 0 ]; then
        log_success "Repository updated successfully."
    else
        log_error "Failed to update repository. Trying to resolve conflicts..."

        # Attempt to resolve conflicts by resetting to the remote state
        log_warning "Resetting to the latest version from the remote repository..."
        git reset --hard origin/main

        if [ $? -eq 0 ]; then
            log_success "Repository reset to the latest version successfully."
        else
            log_error "Failed to reset repository. Please resolve conflicts manually and try again."
            exit 1
        fi
    fi
}

# Function to update containers
update_containers() {
    log_info "Updating containers..."

    # Pull the latest images
    cd "${SCRIPT_DIR}" && docker-compose pull

    if [ $? -eq 0 ]; then
        log_success "Container images updated successfully."
    else
        log_warning "Some container images may not have been updated. Continuing anyway..."
    fi
}

# Function to start containers
start_containers() {
    log_info "Starting containers..."

    cd "${SCRIPT_DIR}" && docker-compose up -d

    if [ $? -eq 0 ]; then
        log_success "Containers started successfully."
    else
        log_error "Failed to start containers. Please check the logs and try to start them manually."
        exit 1
    fi
}

# Function to display update summary
display_summary() {
    log_info "Update summary:"
    log_info "- Update started at: $(date -r "${LOG_FILE}" "+%Y-%m-%d %H:%M:%S")"
    log_info "- Update completed at: $(date "+%Y-%m-%d %H:%M:%S")"
    log_info "- Log file: ${LOG_FILE}"

    # Check if all containers are running
    local running_containers=$(docker-compose ps --services --filter "status=running" | wc -l | tr -d ' ')
    local total_containers=$(docker-compose ps --services | wc -l | tr -d ' ')

    if [ "${running_containers}" -eq "${total_containers}" ]; then
        log_success "All containers are running (${running_containers}/${total_containers})."
    else
        log_warning "Not all containers are running (${running_containers}/${total_containers}). Please check the logs."
    fi

    log_success "PhreakMail has been updated successfully!"
    log_info "You can check the status of your containers with: docker-compose ps"
    log_info "You can view the logs with: docker-compose logs"
}

# Main function
main() {
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}       PhreakMail Update Script         ${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo ""

    # Check dependencies
    check_dependencies

    # Check if the current directory is a git repository
    check_git_repo

    # Check for updates
    check_for_updates

    if [ $? -eq 1 ]; then
        log_info "No updates available. Exiting."
        exit 0
    fi

    # Ask for confirmation
    echo ""
    read -p "Do you want to update PhreakMail? (y/n): " -n 1 -r
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Update cancelled by user."
        exit 0
    fi

    # Create a backup
    create_backup

    # Stop containers
    stop_containers

    # Update the repository
    update_repository

    # Update containers
    update_containers

    # Start containers
    start_containers

    # Display summary
    display_summary
}

# Execute main function
main
