from chat.models import Message, UserStatus, Contact
from rest_framework import serializers
from login.models import User


class UserStatusSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserStatus
        fields = "__all__"


class UserSerializer(serializers.ModelSerializer):
    status = UserStatusSerializer()

    class Meta:
        model = User
        fields = ['id', "username", "status"]


class ContactSerializer(serializers.ModelSerializer):
    class Meta:
        model = Contact
        fields = "__all__"

class MessageSerializer(serializers.ModelSerializer):
    class Meta:
        model = Message
        fields = "__all__"
