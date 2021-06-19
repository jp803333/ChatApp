from django.contrib import admin
from chat.models import User, UserStatus, Message, Contact
# Register your models here.

admin.site.register(Message)
admin.site.register(UserStatus)
admin.site.register(Contact)
