# PhreakMail Django Web Interface

This directory contains a Django-based web interface for PhreakMail, providing a modern and responsive user interface built with Django and Bootstrap.

## Features

- Modern web interface built with Django 4.2 and Bootstrap 5
- Responsive design that works on desktop and mobile devices
- Role-based access control (admin, domain admin, user)
- Integration with existing PhreakMail infrastructure
- Uses the same database as the existing PhreakMail installation

## Directory Structure

```
django_project/
├── manage.py                # Django management script
├── requirements.txt         # Python dependencies
├── docker-compose.django.yml # Docker Compose configuration for Django
├── Dockerfile              # Docker configuration for Django
├── phreakmail/             # Django project directory
│   ├── __init__.py
│   ├── asgi.py
│   ├── settings.py         # Django settings
│   ├── urls.py             # URL configuration
│   └── wsgi.py
└── phreakmail_web/         # Django app directory
    ├── __init__.py
    ├── admin.py            # Django admin configuration
    ├── apps.py
    ├── models.py           # Database models
    ├── urls.py             # URL patterns for the app
    ├── views.py            # View functions
    ├── static/             # Static files (CSS, JS)
    └── templates/          # HTML templates
        ├── base.html       # Base template
        ├── login.html      # Login page
        ├── admin/          # Admin templates
        ├── domainadmin/    # Domain admin templates
        └── user/           # User templates
```

## Installation

### Option 1: Using Docker Compose

1. Make sure you have Docker and Docker Compose installed.

2. Add the Django service to your existing PhreakMail Docker Compose configuration:

   ```bash
   cat docker-compose.django.yml >> ../docker-compose.override.yml
   ```

3. Start the Django service:

   ```bash
   cd ..
   docker-compose up -d django-phreakmail
   ```

### Option 2: Manual Installation

1. Create a Python virtual environment:

   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

2. Install the required packages:

   ```bash
   pip install -r requirements.txt
   ```

3. Run database migrations:

   ```bash
   python manage.py migrate
   ```

4. Create a superuser:

   ```bash
   python manage.py createsuperuser
   ```

5. Start the development server:

   ```bash
   python manage.py runserver
   ```

## Configuration

The Django web interface is configured to work with the existing PhreakMail infrastructure. The main configuration files are:

- `phreakmail/settings.py`: Django settings
- `data/conf/nginx/django.conf`: Nginx configuration for the Django web interface

### Environment Variables

The following environment variables can be used to configure the Django web interface:

- `DJANGO_SECRET_KEY`: Secret key for Django (default: generated)
- `DJANGO_DEBUG`: Enable debug mode (default: False)
- `DB_NAME`: Database name (default: phreakmail)
- `DB_USER`: Database user (default: phreakmail)
- `DB_PASSWORD`: Database password
- `DB_HOST`: Database host (default: mysql-phreakmail)
- `DB_PORT`: Database port (default: 3306)
- `REDIS_HOST`: Redis host (default: redis-phreakmail)
- `REDIS_PORT`: Redis port (default: 6379)
- `REDIS_PASSWORD`: Redis password

## Usage

Once the Django web interface is set up, you can access it at:

- Admin interface: `https://your-phreakmail-hostname/admin/`
- Domain admin interface: `https://your-phreakmail-hostname/domainadmin/`
- User interface: `https://your-phreakmail-hostname/user/`

## Customization

### Templates

The Django web interface uses Bootstrap 5 for styling. You can customize the templates in the `phreakmail_web/templates/` directory.

### Static Files

Static files (CSS, JavaScript, images) are stored in the `phreakmail_web/static/` directory.

### Adding New Features

To add new features to the Django web interface:

1. Create new models in `phreakmail_web/models.py`
2. Create new views in `phreakmail_web/views.py`
3. Add URL patterns in `phreakmail_web/urls.py`
4. Create templates in `phreakmail_web/templates/`

## Integration with PhreakMail

The Django web interface completely replaces the old PHP-based web interface. It uses the same database and authentication system, maintaining compatibility with the rest of the PhreakMail infrastructure.

### Authentication

The Django web interface uses the same authentication system as the existing PhreakMail web interface. Users can log in with their existing PhreakMail credentials.

### Database

The Django web interface uses the same database as the existing PhreakMail installation. It defines Django models that map to the existing database tables.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
