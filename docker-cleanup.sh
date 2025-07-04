#!/bin/bash
# Docker Cleanup Script for phreakmail
# This script will clean up Docker resources to force a fresh pull of all images

# Print colored output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting Docker cleanup...${NC}"

# Stop all running containers
echo -e "${YELLOW}Stopping all running containers...${NC}"
docker-compose down

# Remove all containers, networks, volumes, and images related to the project
echo -e "${YELLOW}Removing all project containers, networks, volumes, and images...${NC}"
docker-compose down --rmi all --volumes --remove-orphans

# Remove any dangling images, containers, networks, and volumes
echo -e "${YELLOW}Removing dangling resources...${NC}"
docker system prune -f

# Ask if user wants to perform a more aggressive cleanup
echo -e "${YELLOW}Do you want to perform a more aggressive cleanup? (y/N)${NC}"
read -r aggressive

if [[ "$aggressive" =~ ^[Yy]$ ]]; then
    echo -e "${RED}Performing aggressive cleanup...${NC}"

    # Stop all containers
    echo -e "${YELLOW}Stopping all Docker containers...${NC}"
    docker stop $(docker ps -aq) 2>/dev/null || true

    # Remove all containers
    echo -e "${YELLOW}Removing all Docker containers...${NC}"
    docker rm -f $(docker ps -aq) 2>/dev/null || true

    # Remove all images
    echo -e "${YELLOW}Removing all Docker images...${NC}"
    docker rmi -f $(docker images -q) 2>/dev/null || true

    # Remove all volumes
    echo -e "${YELLOW}Removing all Docker volumes...${NC}"
    docker volume rm $(docker volume ls -q) 2>/dev/null || true

    # Remove all networks
    echo -e "${YELLOW}Removing all Docker networks...${NC}"
    docker network prune -f

    # Complete system prune
    echo -e "${YELLOW}Performing complete system prune...${NC}"
    docker system prune -a --volumes -f
fi

# Show current Docker resources
echo -e "${GREEN}Cleanup complete! Current Docker resources:${NC}"
echo -e "${YELLOW}Containers:${NC}"
docker ps -a
echo -e "${YELLOW}Images:${NC}"
docker images
echo -e "${YELLOW}Volumes:${NC}"
docker volume ls
echo -e "${YELLOW}Networks:${NC}"
docker network ls

echo -e "${GREEN}Docker cleanup completed successfully!${NC}"
echo -e "${YELLOW}To rebuild and start the stack, run:${NC}"
echo -e "${GREEN}docker-compose build --no-cache${NC}"
echo -e "${GREEN}docker-compose up -d${NC}"

# Suggest Alpine version fix
echo -e "${YELLOW}NOTE: If you're still having issues with Alpine packages, consider modifying your docker-compose.yml to use Alpine 3.16:${NC}"
echo -e "${GREEN}image: alpine:3.16${NC}"

# Suggest Django migration fix
echo -e "${YELLOW}NOTE: If you're still having Django migration issues, consider modifying your docker-compose.override.yml to use:${NC}"
echo -e "${GREEN}command: >
  bash -c \"python manage.py migrate --fake &&
           python manage.py collectstatic --noinput &&
           gunicorn phreakmail.wsgi:application --bind 0.0.0.0:8000\"${NC}"
