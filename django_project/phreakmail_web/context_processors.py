"""
Context processors for the PhreakMail web application.
"""

from phreakmail.version import VERSION

def version_context(request):
    """
    Add version information to the template context.
    """
    return {
        'VERSION': VERSION,
    }
