# PhreakMail Installation Guide

This guide will walk you through the installation of PhreakMail 2.0.0 with the new Django-based web interface.

## System Requirements

- A server running Linux with Docker and Docker Compose installed
- At least 2GB of RAM (4GB recommended)
- At least 20GB of free disk space
- A valid domain name with DNS records pointing to your server

## Quick Installation

```bash
# Clone the repository
git clone https://github.com/phreak/phreakmail.git
cd phreakmail

# Generate configuration
./generate_config.sh

# Start PhreakMail
docker-compose up -d
```

## Detailed Installation Steps

### 1. Prepare Your Server

Make sure your server has Docker and Docker Compose installed:

```bash
# For Ubuntu/Debian
apt update
apt install -y docker.io docker-compose

# For CentOS/RHEL
yum install -y docker docker-compose
systemctl enable docker
systemctl start docker
```

### 2. Clone the Repository

```bash
git clone https://github.com/phreak/phreakmail.git
cd phreakmail
```

### 3. Generate Configuration

Run the configuration generator script:

```bash
./generate_config.sh
```

You will be prompted to enter:
- Your mail server hostname (FQDN)
- Your timezone
- Whether to disable ClamAV (recommended for servers with less than 2.5GB RAM)
- Which branch to use (master, nightly, or legacy)

The script will:
- Generate a random password for the database and Redis
- Create a self-signed SSL certificate
- Set up the Django web interface
- Configure the necessary Docker services

### 4. Start PhreakMail

```bash
docker-compose up -d
```

This will download all necessary Docker images and start the PhreakMail services. The initial startup may take several minutes.

### 5. Access the Web Interface

Once all services are running, you can access the web interface at:

```
https://your-phreakmail-hostname/
```

Default login credentials:
- Username: admin
- Password: phreakMail

**Important:** Change the default password immediately after your first login!

## Post-Installation Steps

### 1. Configure DNS Records

Make sure you have the following DNS records set up for your domain:

- MX record pointing to your mail server
- A/AAAA record for your mail server hostname
- SPF, DKIM, and DMARC records for proper email authentication

### 2. Obtain a Valid SSL Certificate

PhreakMail will automatically attempt to obtain a Let's Encrypt SSL certificate. If this fails, you can manually configure SSL certificates in the web interface.

### 3. Configure Firewall

Make sure the following ports are open on your server:

- 25 (SMTP)
- 465 (SMTPS)
- 587 (Submission)
- 143 (IMAP)
- 993 (IMAPS)
- 110 (POP3)
- 995 (POP3S)
- 80 (HTTP)
- 443 (HTTPS)

## Troubleshooting

If you encounter any issues during installation:

1. Check the logs with `docker-compose logs`
2. For specific service logs, use `docker-compose logs [service-name]`
3. Ensure all required ports are open and not used by other services
4. Verify your DNS records are correctly configured

## Updating PhreakMail

To update PhreakMail to the latest version:

```bash
cd /path/to/phreakmail
./update.sh
```

## Additional Resources

- [PhreakMail Documentation](https://docs.phreakmail.com)
- [GitHub Repository](https://github.com/phreak/phreakmail)
