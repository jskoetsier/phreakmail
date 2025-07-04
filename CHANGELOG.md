# PhreakMail Changelog

All notable changes to the PhreakMail project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2023-07-05

### Added
- Initial release of PhreakMail, forked from mailcow
- Django web application integration for extended functionality
- Custom admin interface for server management
- Comprehensive documentation (README.md, INSTALL.md, SECURITY.md)
- Helper scripts for common administrative tasks:
  - `phreakmail-reset-admin.sh` for resetting admin passwords
  - `backup.sh` for creating complete system backups
  - `docker-cleanup.sh` for cleaning up Docker resources
- Custom entrypoint scripts for container initialization
- Integration with external authentication systems

### Changed
- Renamed project from mailcow to PhreakMail
- Replaced Redis with KeyDB for improved performance and memory efficiency
- Replaced Nginx with Apache web server
- Replaced SOGo webmail client with RainLoop webmail client
- Replaced ClamAV with Comodo for antivirus scanning
- Updated container dependencies and base images
- Improved container startup sequence with proper dependencies
- Enhanced security configurations across all components
- Optimized database queries and connection handling
- Streamlined configuration process with improved `generate_config.sh`

### Removed
- SOGo components and dependencies
- Watchdog container (replaced with Django-based monitoring)
- Olefy container (functionality integrated into Rspamd)
- Netfilter container (replaced with built-in Docker networking)
- Dockerapi container (functionality moved to Django application)

## [0.2.0] - 2023-06-15

### Added
- Preliminary Django integration
- Initial custom configuration files
- Basic helper scripts

### Changed
- Started transition from Redis to KeyDB
- Began modifications to container structure
- Updated base Docker images to newer versions

### Fixed
- Various configuration issues in the original mailcow setup
- Container startup sequence problems
- Database connection handling

## [0.1.0] - 2023-05-20

### Added
- Initial fork of mailcow project
- Basic project structure
- Configuration templates
- Docker Compose setup

## Legacy mailcow Changelog

For the changelog of the original mailcow project that PhreakMail was forked from, please refer to the [mailcow Changelog](https://github.com/mailcow/mailcow-dockerized/blob/master/CHANGELOG.md).

## Migration Notes

### From mailcow to PhreakMail

If you're migrating from mailcow to PhreakMail, please follow these steps:

1. Back up your existing mailcow installation
2. Install PhreakMail following the instructions in INSTALL.md
3. Import your mailcow data using the migration script:
   ```
   ./helper-scripts/migrate-from-mailcow.sh /path/to/mailcow/backup
   ```
4. Verify your email accounts and configuration
5. Update your DNS records if necessary

### Version Upgrade Notes

#### Upgrading to 1.0.0
- Full system backup is recommended before upgrading
- Database schema changes require running the included migration script
- Configuration files will be automatically updated
- Manual review of custom configurations may be necessary

#### Upgrading to 0.2.0
- Backup recommended
- Manual configuration updates required
- No database schema changes
