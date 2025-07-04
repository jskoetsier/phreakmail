#!/bin/bash

# Create directory structure
mkdir -p phreakmail
mkdir -p phreakmail_web
mkdir -p phreakmail_web/templates
mkdir -p phreakmail_web/static
mkdir -p phreakmail_web/static/css
mkdir -p phreakmail_web/static/js
mkdir -p phreakmail_web/templates/admin
mkdir -p phreakmail_web/templates/user
mkdir -p phreakmail_web/templates/domainadmin

# Create main project files
cat > phreakmail/__init__.py << 'EOF'
# Main project initialization
EOF

cat > phreakmail/settings.py << 'EOF'
"""
Django settings for phreakmail project.
"""

import os
from pathlib import Path

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = 'django-insecure-change-this-in-production'

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True

ALLOWED_HOSTS = ['*']  # Change this in production

# Application definition
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'django_bootstrap5',
    'phreakmail_web',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'phreakmail.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'phreakmail.wsgi.application'

# Database
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.environ.get('DB_NAME', 'phreakmail'),
        'USER': os.environ.get('DB_USER', 'phreakmail'),
        'PASSWORD': os.environ.get('DB_PASSWORD', ''),
        'HOST': os.environ.get('DB_HOST', 'localhost'),
        'PORT': os.environ.get('DB_PORT', '5432'),
    }
}

# Password validation
AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

# Internationalization
LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True

# Static files (CSS, JavaScript, Images)
STATIC_URL = 'static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')

# Default primary key field type
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# Custom user model
AUTH_USER_MODEL = 'phreakmail_web.User'

# Login URL
LOGIN_URL = '/login/'
LOGIN_REDIRECT_URL = '/'
LOGOUT_REDIRECT_URL = '/'
EOF

cat > phreakmail/urls.py << 'EOF'
"""
URL configuration for phreakmail project.
"""

from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('phreakmail_web.urls')),
]
EOF

cat > phreakmail/asgi.py << 'EOF'
"""
ASGI config for phreakmail project.
"""

import os

from django.core.asgi import get_asgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'phreakmail.settings')

application = get_asgi_application()
EOF

cat > phreakmail/wsgi.py << 'EOF'
"""
WSGI config for phreakmail project.
"""

import os

from django.core.wsgi import get_wsgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'phreakmail.settings')

application = get_wsgi_application()
EOF

# Create app files
cat > phreakmail_web/__init__.py << 'EOF'
# App initialization
EOF

cat > phreakmail_web/apps.py << 'EOF'
from django.apps import AppConfig

class PhreakmailWebConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'phreakmail_web'
EOF

cat > phreakmail_web/models.py << 'EOF'
from django.db import models
from django.contrib.auth.models import AbstractUser

class User(AbstractUser):
    """Custom user model for phreakmail"""
    ROLE_CHOICES = (
        ('admin', 'Administrator'),
        ('domainadmin', 'Domain Administrator'),
        ('user', 'User'),
    )
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='user')

    def is_admin(self):
        return self.role == 'admin'

    def is_domainadmin(self):
        return self.role == 'domainadmin'

    def is_mailbox_user(self):
        return self.role == 'user'

class Domain(models.Model):
    """Domain model"""
    name = models.CharField(max_length=255, unique=True)
    description = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    active = models.BooleanField(default=True)

    def __str__(self):
        return self.name

class Mailbox(models.Model):
    """Mailbox model"""
    username = models.CharField(max_length=255, unique=True)
    domain = models.ForeignKey(Domain, on_delete=models.CASCADE)
    name = models.CharField(max_length=255)
    active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.username}@{self.domain.name}"
EOF

cat > phreakmail_web/views.py << 'EOF'
from django.shortcuts import render, redirect
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required
from django.views.decorators.http import require_http_methods
from django.http import HttpResponse
from .models import User, Domain, Mailbox

def index(request):
    """Main index view"""
    if request.user.is_authenticated:
        if request.user.is_admin():
            return redirect('admin_dashboard')
        elif request.user.is_domainadmin():
            return redirect('domainadmin_mailbox')
        else:
            return redirect('user_dashboard')
    return render(request, 'login.html')

@require_http_methods(["POST"])
def login_view(request):
    """Handle login"""
    username = request.POST.get('username')
    password = request.POST.get('password')
    user = authenticate(request, username=username, password=password)

    if user is not None:
        login(request, user)
        if user.is_admin():
            return redirect('admin_dashboard')
        elif user.is_domainadmin():
            return redirect('domainadmin_mailbox')
        else:
            return redirect('user_dashboard')
    else:
        return render(request, 'login.html', {'error': 'Invalid credentials'})

def logout_view(request):
    """Handle logout"""
    logout(request)
    return redirect('index')

@login_required
def admin_dashboard(request):
    """Admin dashboard view"""
    if not request.user.is_admin():
        return redirect('index')

    domains = Domain.objects.all()
    mailboxes = Mailbox.objects.all()

    context = {
        'domains': domains,
        'mailboxes': mailboxes,
    }

    return render(request, 'admin/dashboard.html', context)

@login_required
def domainadmin_mailbox(request):
    """Domain admin mailbox view"""
    if not request.user.is_domainadmin():
        return redirect('index')

    # In a real implementation, we would filter domains by the domain admin's access
    domains = Domain.objects.all()
    mailboxes = Mailbox.objects.all()

    context = {
        'domains': domains,
        'mailboxes': mailboxes,
    }

    return render(request, 'domainadmin/mailbox.html', context)

@login_required
def user_dashboard(request):
    """User dashboard view"""
    if not request.user.is_mailbox_user():
        return redirect('index')

    # In a real implementation, we would get the user's mailbox

    context = {
        'user': request.user,
    }

    return render(request, 'user/dashboard.html', context)
EOF

cat > phreakmail_web/urls.py << 'EOF'
from django.urls import path
from . import views

urlpatterns = [
    path('', views.index, name='index'),
    path('login/', views.login_view, name='login'),
    path('logout/', views.logout_view, name='logout'),
    path('admin/dashboard/', views.admin_dashboard, name='admin_dashboard'),
    path('domainadmin/mailbox/', views.domainadmin_mailbox, name='domainadmin_mailbox'),
    path('user/', views.user_dashboard, name='user_dashboard'),
]
EOF

cat > phreakmail_web/admin.py << 'EOF'
from django.contrib import admin
from .models import User, Domain, Mailbox

admin.site.register(User)
admin.site.register(Domain)
admin.site.register(Mailbox)
EOF

# Create templates
cat > phreakmail_web/templates/base.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{% block title %}PhreakMail{% endblock %}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    {% block extra_css %}{% endblock %}
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="/">PhreakMail</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto">
                    {% if user.is_authenticated %}
                        {% if user.is_admin %}
                        <li class="nav-item">
                            <a class="nav-link" href="{% url 'admin_dashboard' %}">Dashboard</a>
                        </li>
                        {% elif user.is_domainadmin %}
                        <li class="nav-item">
                            <a class="nav-link" href="{% url 'domainadmin_mailbox' %}">Mailboxes</a>
                        </li>
                        {% else %}
                        <li class="nav-item">
                            <a class="nav-link" href="{% url 'user_dashboard' %}">Dashboard</a>
                        </li>
                        {% endif %}
                    {% endif %}
                </ul>
                <ul class="navbar-nav">
                    {% if user.is_authenticated %}
                    <li class="nav-item">
                        <a class="nav-link" href="{% url 'logout' %}">Logout</a>
                    </li>
                    {% else %}
                    <li class="nav-item">
                        <a class="nav-link" href="{% url 'login' %}">Login</a>
                    </li>
                    {% endif %}
                </ul>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        {% block content %}{% endblock %}
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    {% block extra_js %}{% endblock %}
</body>
</html>
EOF

cat > phreakmail_web/templates/login.html << 'EOF'
{% extends 'base.html' %}

{% block title %}Login - PhreakMail{% endblock %}

{% block content %}
<div class="row justify-content-center">
    <div class="col-md-6">
        <div class="card">
            <div class="card-header">
                <h4 class="mb-0">Login to PhreakMail</h4>
            </div>
            <div class="card-body">
                {% if error %}
                <div class="alert alert-danger">{{ error }}</div>
                {% endif %}
                <form method="post" action="{% url 'login' %}">
                    {% csrf_token %}
                    <div class="mb-3">
                        <label for="username" class="form-label">Username</label>
                        <input type="text" class="form-control" id="username" name="username" required>
                    </div>
                    <div class="mb-3">
                        <label for="password" class="form-label">Password</label>
                        <input type="password" class="form-control" id="password" name="password" required>
                    </div>
                    <button type="submit" class="btn btn-primary">Login</button>
                </form>
            </div>
        </div>
    </div>
</div>
{% endblock %}
EOF

cat > phreakmail_web/templates/admin/dashboard.html << 'EOF'
{% extends 'base.html' %}

{% block title %}Admin Dashboard - PhreakMail{% endblock %}

{% block content %}
<h1>Admin Dashboard</h1>

<div class="row mt-4">
    <div class="col-md-6">
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0">Domains</h5>
            </div>
            <div class="card-body">
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>Name</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {% for domain in domains %}
                        <tr>
                            <td>{{ domain.name }}</td>
                            <td>
                                {% if domain.active %}
                                <span class="badge bg-success">Active</span>
                                {% else %}
                                <span class="badge bg-danger">Inactive</span>
                                {% endif %}
                            </td>
                            <td>
                                <a href="#" class="btn btn-sm btn-primary">Edit</a>
                                <a href="#" class="btn btn-sm btn-danger">Delete</a>
                            </td>
                        </tr>
                        {% empty %}
                        <tr>
                            <td colspan="3">No domains found</td>
                        </tr>
                        {% endfor %}
                    </tbody>
                </table>
                <a href="#" class="btn btn-success">Add Domain</a>
            </div>
        </div>
    </div>

    <div class="col-md-6">
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0">Mailboxes</h5>
            </div>
            <div class="card-body">
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>Email</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {% for mailbox in mailboxes %}
                        <tr>
                            <td>{{ mailbox }}</td>
                            <td>
                                {% if mailbox.active %}
                                <span class="badge bg-success">Active</span>
                                {% else %}
                                <span class="badge bg-danger">Inactive</span>
                                {% endif %}
                            </td>
                            <td>
                                <a href="#" class="btn btn-sm btn-primary">Edit</a>
                                <a href="#" class="btn btn-sm btn-danger">Delete</a>
                            </td>
                        </tr>
                        {% empty %}
                        <tr>
                            <td colspan="3">No mailboxes found</td>
                        </tr>
                        {% endfor %}
                    </tbody>
                </table>
                <a href="#" class="btn btn-success">Add Mailbox</a>
            </div>
        </div>
    </div>
</div>
{% endblock %}
EOF

cat > phreakmail_web/templates/domainadmin/mailbox.html << 'EOF'
{% extends 'base.html' %}

{% block title %}Domain Admin - Mailboxes - PhreakMail{% endblock %}

{% block content %}
<h1>Domain Admin - Mailboxes</h1>

<div class="card mt-4">
    <div class="card-header">
        <h5 class="mb-0">Mailboxes</h5>
    </div>
    <div class="card-body">
        <table class="table table-striped">
            <thead>
                <tr>
                    <th>Email</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                {% for mailbox in mailboxes %}
                <tr>
                    <td>{{ mailbox }}</td>
                    <td>
                        {% if mailbox.active %}
                        <span class="badge bg-success">Active</span>
                        {% else %}
                        <span class="badge bg-danger">Inactive</span>
                        {% endif %}
                    </td>
                    <td>
                        <a href="#" class="btn btn-sm btn-primary">Edit</a>
                        <a href="#" class="btn btn-sm btn-danger">Delete</a>
                    </td>
                </tr>
                {% empty %}
                <tr>
                    <td colspan="3">No mailboxes found</td>
                </tr>
                {% endfor %}
            </tbody>
        </table>
        <a href="#" class="btn btn-success">Add Mailbox</a>
    </div>
</div>
{% endblock %}
EOF

cat > phreakmail_web/templates/user/dashboard.html << 'EOF'
{% extends 'base.html' %}

{% block title %}User Dashboard - PhreakMail{% endblock %}

{% block content %}
<h1>User Dashboard</h1>

<div class="row mt-4">
    <div class="col-md-6">
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0">Account Information</h5>
            </div>
            <div class="card-body">
                <p><strong>Username:</strong> {{ user.username }}</p>
                <p><strong>Email:</strong> {{ user.email }}</p>
                <p><strong>Last Login:</strong> {{ user.last_login }}</p>
                <a href="#" class="btn btn-primary">Change Password</a>
            </div>
        </div>
    </div>

    <div class="col-md-6">
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0">Email Statistics</h5>
            </div>
            <div class="card-body">
                <p><strong>Inbox:</strong> 0 messages</p>
                <p><strong>Sent:</strong> 0 messages</p>
                <p><strong>Spam:</strong> 0 messages</p>
                <p><strong>Trash:</strong> 0 messages</p>
                <a href="#" class="btn btn-primary">Go to Webmail</a>
            </div>
        </div>
    </div>
</div>
{% endblock %}
EOF

# Create Docker files
cat > Dockerfile << 'EOF'
FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . .

# Run migrations and collect static files
RUN python manage.py collectstatic --noinput

# Expose port
EXPOSE 8000

# Run the application
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "phreakmail.wsgi:application"]
EOF

cat > docker-compose.yml << 'EOF'
version: '3'

services:
  web:
    build: .
    restart: always
    ports:
      - "8000:8000"
    depends_on:
      - db
    environment:
      - DB_NAME=phreakmail
      - DB_USER=phreakmail
      - DB_PASSWORD=phreakmail
      - DB_HOST=db
      - DB_PORT=5432
      - DJANGO_SETTINGS_MODULE=phreakmail.settings
      - DJANGO_SECRET_KEY=change-this-in-production
    volumes:
      - ./:/app
    command: >
      bash -c "python manage.py migrate &&
               python manage.py runserver 0.0.0.0:8000"

  db:
    image: postgres:15
    restart: always
    environment:
      - POSTGRES_DB=phreakmail
      - POSTGRES_USER=phreakmail
      - POSTGRES_PASSWORD=phreakmail
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
EOF

echo "Django project structure created successfully!"
echo "To start the development server, run:"
echo "  cd django_project"
echo "  python manage.py migrate"
echo "  python manage.py createsuperuser"
echo "  python manage.py runserver"
echo ""
echo "To use Docker, run:"
echo "  docker-compose up -d"
