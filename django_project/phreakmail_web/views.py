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
