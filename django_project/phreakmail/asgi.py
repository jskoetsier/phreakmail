"""
ASGI config for phreakmail project.
"""

import os

from django.core.asgi import get_asgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'phreakmail.settings')

application = get_asgi_application()
