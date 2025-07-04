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
