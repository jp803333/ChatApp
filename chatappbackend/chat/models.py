from django.db import models
from django.db.utils import IntegrityError
from django.conf import settings
from django.contrib.auth.models import AbstractUser

from django.dispatch import receiver
from django.db.models.signals import post_save
from login.models import User


class UserStatus(models.Model):
    online = models.IntegerField(default=0)
    lastseen = models.DateTimeField(auto_now_add=True)

    user = models.OneToOneField(
        User, on_delete=models.CASCADE, related_name="status")

    def __str__(self):
        return f'{self.user.username} {self.online} {self.lastseen}'


class Contact(models.Model):
    user = models.ForeignKey(
        User, on_delete=models.CASCADE, related_name="contacts")
    touser = models.ForeignKey(
        User, on_delete=models.CASCADE, related_name="inotherscontacts")
    is_deleted = models.BooleanField(default=False)
    deleted_last = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username} | {self.touser.username}  | {self.is_deleted} | {self.deleted_last}"

    class Meta:
        unique_together = (('user', 'touser'),)


@receiver(post_save, sender=User)
def create_userstatus_and_chatroom(sender, instance, created, **kwargs):
    if created:
        UserStatus(user=instance).save()

class Message(models.Model):
    message = models.TextField(max_length=500, blank=True)
    fromuser = models.ForeignKey(
        User, on_delete=models.CASCADE, related_name="sentmessages")
    touser = models.ForeignKey(
        User, on_delete=models.CASCADE, related_name="incomingmessages")
    seen_by_to_user = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Message from {self.fromuser.username} to {self.touser.username} at {self.created_at}"
