from django.contrib.auth.models import AnonymousUser
from django.core.asgi import get_asgi_application
from django.urls import re_path

from channels.middleware import BaseMiddleware
from channels.db import database_sync_to_async
from channels.routing import ProtocolTypeRouter, URLRouter
from channels.auth import AuthMiddlewareStack

from rest_framework.authtoken.models import Token

import os

import chat.websockets.routing


os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'chatappbackend.settings')


@database_sync_to_async
def get_user(token_key):
    try:
        token = Token.objects.get(key=token_key)
        return token.user
    except Token.DoesNotExist:
        return AnonymousUser()


class TokenAuthMiddleware(BaseMiddleware):

    def __init__(self, inner):
        self.inner = inner

    async def __call__(self, scope, receive, send):
        headers = dict(scope['headers'])
        if b'authorization' in headers:
            try:
                token_name, token_key = headers[b'authorization'].decode(
                ).split()
                scope['user'] = await get_user(token_key)
            except Token.DoesNotExist:
                scope['user'] = AnonymousUser()
        return await super().__call__(scope, receive, send)


application = ProtocolTypeRouter({
    "http": get_asgi_application(),
    "websocket": TokenAuthMiddleware(
        URLRouter(
            chat.websockets.routing.websocket_urlpatterns
        )
    ),
})
