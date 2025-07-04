# PhreakMail Installation Guide

This guide provides detailed instructions for installing and configuring PhreakMail on your server.

## System Requirements

- **Operating System**: Linux (Debian/Ubuntu recommended), macOS (for development only)
- **CPU**: 2+ cores recommended (4+ for production use)
- **RAM**: 4GB minimum (8GB+ recommended for production use)
- **Storage**: 20GB minimum for the system, plus storage for emails (SSD recommended)
- **Network**: Static IP address with ports 25, 80, 443, 465, 587, 993, 995 available
- **DNS**: Proper DNS records for your mail domain

## Prerequisites

### Software Requirements

- Docker Engine (version 20.10.0 or higher)
- Docker Compose (version 2.0.0 or higher)
- Git

### DNS Configuration

Before installation, ensure you have set up the following DNS records for your domain:

1. **MX Record**:
   ```
   @ IN MX 10 mail.yourdomain.com.
   ```

2. **A Records**:
   ```
   mail IN A your.server.ip.address
   autoconfig IN A your.server.ip.address
   autodiscover IN A your.server.ip.address
   ```

3. **PTR Record** (Reverse DNS):
   - Set up a PTR record for your server's IP address pointing to mail.yourdomain.com
   - This typically needs to be configured with your hosting provider or ISP

4. **SPF Record**:
   ```
   @ IN TXT "v=spf1 mx ~all"
   ```

5. **DKIM Record** (will be generated during installation):
   ```
   dkim._domainkey IN TXT "v=DKIM1; k=rsa; p=..."
   ```

6. **DMARC Record**:
   ```
   _dmarc IN TXT "v=DMARC1; p=none; rua=mailto:postmaster@yourdomain.com"
   ```

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/phreakmail.git
cd phreakmail
```

### 2. Generate Configuration

Run the configuration generator script:

```bash
./generate_config.sh
```

This interactive script will:
- Create a `phreakmail.conf` file with your settings
- Generate random passwords for services
- Configure domain settings

### 3. Edit Configuration (Optional)

If you need to customize your configuration beyond the interactive setup:

```bash
nano phreakmail.conf
```

Key settings you might want to adjust:
- `PHREAKMAIL_HOSTNAME`: Your mail server's hostname
- `DBROOT`: MariaDB root password
- `DBNAME`, `DBUSER`, `DBPASS`: Database connection details
- `KEYDBPASS`: KeyDB password
- `TZ`: Timezone setting
- `ADDITIONAL_SERVER_NAMES`: Additional hostnames for your mail server

### 4. Start the Containers

```bash
docker-compose up -d
```

This command will:
- Pull all required Docker images
- Create necessary volumes and networks
- Start all PhreakMail services

The initial startup may take several minutes as Docker downloads and initializes all components.

### 5. Verify Installation

Check that all containers are running:

```bash
docker-compose ps
```

All containers should show a status of "Up".

### 6. Access the Web Interface

Open your web browser and navigate to:

```
https://mail.yourdomain.com/admin
```

Log in with the default credentials:
- Username: `admin`
- Password: (found in your `phreakmail.conf` file as `ADMIN_PASSWORD`)

**Important**: Change the default password immediately after your first login.

## Post-Installation Configuration

### 1. Create Email Domains

1. Log in to the admin interface
2. Navigate to "Domains" > "Add Domain"
3. Enter your domain name and configure settings
4. Click "Save"

### 2. Create Email Accounts

1. Navigate to "Accounts" > "Add Account"
2. Enter account details (username, password, etc.)
3. Assign to a domain
4. Set quotas and permissions
5. Click "Save"

### 3. Configure SSL Certificates

PhreakMail automatically manages SSL certificates using ACME (Let's Encrypt). To verify:

1. Navigate to "Configuration" > "SSL"
2. Ensure your domains are listed with valid certificates
3. If needed, request new certificates using the "Request Certificate" button

### 4. Configure Spam Protection

1. Navigate to "Configuration" > "Rspamd"
2. Adjust spam scoring thresholds
3. Configure whitelists and blacklists
4. Enable or disable specific modules

### 5. Configure Backup

Set up regular backups of your PhreakMail data:

```bash
# Create a backup directory
mkdir -p /path/to/backup/location

# Add a cron job to run backups regularly
crontab -e

# Add this line to run daily backups at 2 AM
0 2 * * * cd /path/to/phreakmail && ./helper-scripts/backup.sh /path/to/backup/location
```

## Accessing Email

### Webmail

Access the RainLoop webmail client at:

```
https://mail.yourdomain.com/webmail
```

### Email Clients

Configure your email clients with these settings:

**IMAP Settings**:
- Server: mail.yourdomain.com
- Port: 993
- Security: SSL/TLS
- Authentication: Normal Password

**SMTP Settings**:
- Server: mail.yourdomain.com
- Port: 587 (with STARTTLS) or 465 (with SSL/TLS)
- Security: STARTTLS or SSL/TLS
- Authentication: Normal Password

## Firewall Configuration

Ensure your firewall allows these ports:

- 25 (SMTP): Incoming mail
- 80 (HTTP): For ACME verification (redirects to HTTPS)
- 443 (HTTPS): Web interfaces
- 465 (SMTPS): Secure mail submission
- 587 (Submission): Mail submission with STARTTLS
- 993 (IMAPS): Secure IMAP
- 995 (POP3S): Secure POP3

Example for UFW:

```bash
ufw allow 25/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 465/tcp
ufw allow 587/tcp
ufw allow 993/tcp
ufw allow 995/tcp
```

## Troubleshooting

### Container Startup Issues

If containers fail to start:

```bash
# Check container logs
docker-compose logs [service-name]

# Restart a specific service
docker-compose restart [service-name]

# Restart all services
docker-compose restart
```

### Database Connection Issues

If services can't connect to the database:

```bash
# Check MariaDB logs
docker-compose logs mysql-phreakmail

# Access MariaDB shell
docker-compose exec mysql-phreakmail mysql -u root -p
```

### SSL Certificate Issues

If ACME fails to obtain certificates:

```bash
# Check ACME logs
docker-compose logs acme-phreakmail

# Verify DNS settings
dig A mail.yourdomain.com
dig MX yourdomain.com
```

### Email Delivery Issues

If emails aren't being delivered:

```bash
# Check Postfix logs
docker-compose logs postfix-phreakmail

# Check mail queue
docker-compose exec postfix-phreakmail postqueue -p

# Test SMTP connection
telnet mail.yourdomain.com 25
```

## Updating PhreakMail

To update to the latest version:

```bash
cd /path/to/phreakmail
git pull
docker-compose pull
docker-compose down
docker-compose up -d
```

## Additional Resources

- [PhreakMail Documentation](https://docs.phreakmail.org)
- [Troubleshooting Guide](https://docs.phreakmail.org/troubleshooting)
- [Security Best Practices](https://docs.phreakmail.org/security)
- [Community Forum](https://forum.phreakmail.org)

## Support

For support, please visit:
- GitHub Issues: https://github.com/yourusername/phreakmail/issues
- Community Forum: https://forum.phreakmail.org
- Email Support: support@phreakmail.org
