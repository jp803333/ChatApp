from rest_framework.response import Response
from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.authtoken.models import Token

from login.api.serializers import RegistrationSerializer
from login.models import User
from django.contrib.auth.models import AnonymousUser
import json
from django.http.response import JsonResponse
from django.core import serializers
from chat.models import Contact


@api_view(['POST', ])
def search(request):
    if "keyword" in request.data.keys() and request.user.is_authenticated:
        users = User.objects.filter(username__contains=request.data["keyword"]).exclude(
            username=request.user.username)
        print(users)
        return Response({'users': serializers.serialize('json', users)}, status=status.HTTP_200_OK)
    else:
        return Response(status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST', ])
def addContact(request):
    if "username" in request.data.keys() and request.user.is_authenticated :
        if request.user.username != request.data["username"]:
            try:
                touser = User.objects.get(username=request.data.get("username"))
            except User.DoesNotExist:
                return Response(status=status.HTTP_404_NOT_FOUND)
            try:
                contact = Contact.objects.get(user=request.user, touser=touser)
            except Contact.DoesNotExist:
                contact = Contact(user=request.user, touser=touser)
                contact.save()
                pass
            print(contact)
        return Response(status=status.HTTP_200_OK)
    else:
        return Response(status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST', ])
def logout_view(request):
    if request.method == 'POST':
        request.user.auth_token.delete()
        return Response({"detail": "Logout Complete"}, status=status.HTTP_200_OK)


@api_view(['POST', ])
def login_view(request):
    if request.method == 'POST':
        if "username" in request.data.keys():
            try:
                user = User.objects.get(username=request.data.get("username"))
            except User.DoesNotExist:
                user = User(username=request.data.get("username"))
                user.save()
            token, created = Token.objects.get_or_create(user=user)
            return Response(data={"token": str(token)}, status=status.HTTP_200_OK)
        else:
            return Response({"detail": "Username not proper"},
                            status=status.HTTP_400_BAD_REQUEST)
