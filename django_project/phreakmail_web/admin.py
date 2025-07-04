from django.contrib import admin
from .models import User, Domain, Mailbox

admin.site.register(User)
admin.site.register(Domain)
admin.site.register(Mailbox)
