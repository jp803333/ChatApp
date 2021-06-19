from django.urls import path, include

from login.api.views import logout_view, login_view

urlpatterns = [
    path('login/', login_view, name='login'),
    path('logout/', logout_view, name='logout'),
]
