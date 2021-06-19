from django.db import models

from django.contrib.auth.models import AbstractUser
from django.contrib.auth.base_user import AbstractBaseUser, BaseUserManager
from django.contrib.auth.models import PermissionsMixin


class User(AbstractUser):

    username = models.CharField(max_length=100, blank=True, unique=True)

    def __str__(self):
        return self.username
