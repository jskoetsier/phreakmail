# PhreakMail

## Version 2.0.0

PhreakMail is a dockerized mail server solution with a modern Django-based web interface, designed to be easy to deploy and maintain.

## Features

- **Modern Web Interface**: Built with Django and Bootstrap 5
- **Responsive Design**: Works seamlessly on desktop and mobile devices
- **Role-Based Access Control**: Admin, domain admin, and user roles
- **Dockerized**: Easy deployment with Docker and Docker Compose
- **Secure**: TLS encryption, spam filtering, and virus scanning
- **Complete Email Solution**: SMTP, IMAP, POP3, and webmail

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

After installation, access the web interface at `https://your-phreakmail-hostname/`.

## Web Interface

The PhreakMail web interface is built with Django and Bootstrap 5, providing a modern and responsive user experience:

- **Admin Interface**: `https://your-phreakmail-hostname/admin/`
- **Domain Admin Interface**: `https://your-phreakmail-hostname/domainadmin/`
- **User Interface**: `https://your-phreakmail-hostname/user/`

## Documentation

For detailed documentation, please visit [docs.phreakmail.com](https://docs.phreakmail.com).

## Security

If you discover a security vulnerability, please send an email to [contact@phreakmail.com](mailto:contact@phreakmail.com).

## License

PhreakMail is released under the MIT License.

Copyright (c) 2024 phreak

## Important Note

PhreakMail makes use of various open-source software. Please ensure you agree with their licenses before using PhreakMail.
