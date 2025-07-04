# Security Policy

## PhreakMail Security Overview

PhreakMail is designed with security as a core principle. This document outlines the security features, best practices, and vulnerability reporting procedures for PhreakMail.

## Security Features

PhreakMail includes the following security features:

### Email Security

- **TLS Encryption**: Enforced for all mail transport protocols (SMTP, IMAP, POP3)
- **DKIM Signing**: Automatic email signing to verify message authenticity
- **SPF & DMARC Support**: Protection against email spoofing and phishing
- **Greylisting**: Protection against spam by temporarily rejecting emails from unknown senders
- **Rate Limiting**: Protection against brute force attacks and abuse

### Content Security

- **Comodo Antivirus**: Enterprise-grade scanning of all incoming and outgoing emails
- **Rspamd**: Advanced spam filtering with machine learning capabilities
- **Attachment Filtering**: Blocking of potentially dangerous file types
- **URL Filtering**: Protection against phishing links
- **DNSBL Integration**: Blocking emails from known spam sources

### Authentication & Access Control

- **Strong Password Policies**: Enforced minimum complexity requirements
- **Two-Factor Authentication**: Optional 2FA for admin and user accounts
- **IP-based Access Controls**: Restrict access to admin interfaces
- **Role-based Permissions**: Granular control over user capabilities
- **Brute Force Protection**: Account lockout after failed login attempts

### Infrastructure Security

- **Container Isolation**: Each service runs in its own Docker container
- **Automatic Updates**: Security patches applied through regular updates
- **SSL/TLS Certificates**: Automatic management via ACME protocol
- **Network Isolation**: Internal services not exposed to the internet
- **Firewall Rules**: Restrictive network policies between containers

## Security Best Practices

### Installation & Configuration

1. **Use Strong Passwords**: Set strong, unique passwords for all accounts, especially:
   - Database root password
   - KeyDB password
   - Admin account password

2. **Network Security**:
   - Place PhreakMail behind a reverse proxy or load balancer for additional security
   - Use a dedicated firewall to restrict access to mail ports
   - Consider implementing GeoIP blocking for admin interfaces

3. **SSL/TLS Configuration**:
   - Use valid, trusted SSL certificates (automatically managed by ACME)
   - Disable outdated TLS protocols (TLS 1.0/1.1)
   - Use strong cipher suites

4. **DNS Configuration**:
   - Implement proper SPF, DKIM, and DMARC records
   - Consider DNSSEC for your domain
   - Set appropriate MX, A, and PTR records

### Ongoing Maintenance

1. **Regular Updates**:
   - Keep PhreakMail updated to the latest version
   - Monitor security announcements for component vulnerabilities
   - Apply security patches promptly

2. **Monitoring & Logging**:
   - Enable comprehensive logging
   - Regularly review logs for suspicious activity
   - Consider integrating with a SIEM solution

3. **Backup & Recovery**:
   - Perform regular backups of all data
   - Test restoration procedures
   - Store backups securely off-site

4. **Access Management**:
   - Regularly audit user accounts and permissions
   - Remove unused accounts
   - Rotate administrative credentials periodically

## Vulnerability Reporting

We take security vulnerabilities seriously. If you discover a security issue in PhreakMail, please follow these steps:

1. **Do Not Disclose Publicly**: Please do not disclose the vulnerability publicly until it has been addressed.

2. **Report Directly**: Send details of the vulnerability to security@phreakmail.org with the following information:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Any suggested mitigations (if known)

3. **Encryption**: For sensitive reports, you can encrypt your message using our PGP key, available at https://phreakmail.org/security-key.asc

### What to Expect

- **Acknowledgment**: We will acknowledge receipt of your report within 48 hours.
- **Investigation**: We will investigate the issue and determine its impact and severity.
- **Updates**: We will provide regular updates on our progress.
- **Resolution**: Once resolved, we will notify you and provide details of the fix.
- **Recognition**: With your permission, we will acknowledge your contribution in our release notes.

## Security Updates

PhreakMail security updates are distributed through the following channels:

1. **GitHub Releases**: All security fixes are included in regular releases.
2. **Security Advisories**: Critical vulnerabilities are announced via GitHub Security Advisories.
3. **Mailing List**: Subscribe to security@phreakmail.org for direct notifications.

### Update Policy

- **Critical Vulnerabilities**: Patches released within 48 hours
- **High Severity**: Patches released within 7 days
- **Medium/Low Severity**: Addressed in the next regular release

## Security Compliance

PhreakMail is designed to help organizations comply with various security standards and regulations, including:

- GDPR (General Data Protection Regulation)
- HIPAA (Health Insurance Portability and Accountability Act)
- PCI DSS (Payment Card Industry Data Security Standard)

However, compliance ultimately depends on proper configuration and organizational policies. PhreakMail provides the technical foundation, but organizations must implement appropriate procedures and controls.

## Security Hardening Guide

For detailed instructions on hardening your PhreakMail installation, please refer to our [Security Hardening Guide](docs/security-hardening.md).

## Contact

For security-related inquiries, please contact:
- Email: security@phreakmail.org
- PGP Key: https://phreakmail.org/security-key.asc
