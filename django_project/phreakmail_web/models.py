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
