
import json
from django.shortcuts import get_object_or_404
from django.db import models

from asgiref.sync import sync_to_async, async_to_sync
from channels.generic.websocket import AsyncWebsocketConsumer, WebsocketConsumer
from channels.layers import get_channel_layer

from chat.models import Message, UserStatus, Contact
from chat.websockets.serializers import MessageSerializer, UserSerializer, UserStatusSerializer, ContactSerializer


from datetime import datetime
from login.models import User

def addGroupToChannellayer(group_name, channel_name):
    channel_layer = get_channel_layer()
    async_to_sync(channel_layer.group_add)(
        group_name,
        channel_name
    )


def discardGroupFromChannellayer(group_name, channel_name):
    channel_layer = get_channel_layer()
    async_to_sync(channel_layer.group_discard)(
        group_name,
        channel_name
    )


class ChatRoomConsumer(WebsocketConsumer):

    def connect(self):
        # check if auth token is there or not
        if (not "user" in self.scope.keys()):
            print("no auth key")
            self.close()
        else:
            try:
                self.userStatus = UserStatus.objects.get(
                    user=self.scope['user'])
            except UserStatus.DoesNotExist:
                self.userStatus = UserStatus(user=self.scope['user'])
                self.userStatus.save()

            self.userStatus.online += 1
            self.userStatus.save()
            self.group_name = str(self.scope['user'].pk)

            contacts = Contact.objects.filter(
                user=self.scope['user'].pk)
            contactsSerialized = ContactSerializer(contacts, many=True).data
            for contact in contactsSerialized:
                messages = MessageSerializer(Message.objects.filter(
                    fromuser=self.scope['user'], touser__pk=contact['touser'], created_at__gte=contact['deleted_last']), many=True).data
                othermessages = MessageSerializer(Message.objects.filter(
                    touser=self.scope['user'], fromuser__pk=contact['touser'], created_at__gte=contact['deleted_last']), many=True).data
                contactUsers = UserSerializer(
                    User.objects.get(pk=contact['touser']))
                contact['touser'] = contactUsers.data
                contact['message'] = messages + othermessages
            addGroupToChannellayer(self.group_name, self.channel_name)
            self.accept()
            self.send(text_data=json.dumps({
                "response_type": "all_chats",
                "contacts": contactsSerialized,
            }))

    def receive(self, text_data=None):
        text_data_json = json.loads(text_data)
        command = text_data_json['command']

        if command == "send_message":
            touser = text_data_json['touser']
            touser = User.objects.get(pk=touser)
            # if contact is not present in the contacts of the user who is sending the message
            try:
                sender = Contact.objects.get(
                    user=self.scope['user'], touser=touser)
                if sender.is_deleted:
                    sender.is_deleted = False
                    sender.save()
            except Contact.DoesNotExist:
                sender = Contact(user=self.scope['user'],
                                 touser=touser)
                sender.save()

            # To check if the receive have sender in its contact list
            justAddedSendersContactForReceiver = False
            # If the receiver had deleted the senders contact
            receiverDeletedSendersContact = False
            try:
                receiver = Contact.objects.get(
                    user=touser, touser=self.scope['user'])
                if receiver.is_deleted:
                    receiverDeletedSendersContact = True
                    receiver.is_deleted = False
                    receiver.save()
            except Contact.DoesNotExist:
                receiver = Contact(user=touser, touser=self.scope['user'])
                receiver.save()
                justAddedSendersContactForReceiver = True

            message = text_data_json['message']
            message = Message(touser=touser,
                              message=message, fromuser=self.scope['user'])
            message.save()
            data = MessageSerializer(message).data
                
            if justAddedSendersContactForReceiver or receiverDeletedSendersContact:
                contact = ContactSerializer(receiver).data
                contactUsers = UserSerializer(
                    User.objects.get(pk=self.scope['user'].pk))
                contact['touser'] = contactUsers.data
                async_to_sync(self.channel_layer.group_send)(
                    str(touser.pk),
                    {
                        'type': 'send_message_to_other_group',
                        "sent_by": contact,
                        'message': data,
                    }
                )
            else:
                async_to_sync(self.channel_layer.group_send)(
                    str(touser.pk),
                    {
                        'type': 'send_message_to_other_group',
                        "sent_by": ContactSerializer(receiver).data,
                        'message': data,
                    }
                )

            self.send(text_data=json.dumps({
                "response_type": "new_message",
                "sent_by": "self",
                'new_message': data}))
            pass
        # elif command == "user_status":
        #     data = []
        #     contacts = Contact.objects.filter(
        #         user=self.scope['user'].pk, is_blocked=False)
        #     contactsSerialized = ContactSerializer(contacts, many=True).data
        #     for contact in contactsSerialized:
        #         contactUsers = UserSerializer(
        #             User.objects.get(pk=contact['touser']))
        #         data.append(contactUsers.data)
        #     self.send(text_data=json.dumps({
        #         "response_type": "user_status",
        #         "users": data}))
        elif command == "user_status_by_id":
            print("user_status_by_id")
            contactUsers = UserSerializer(
                User.objects.get(id=text_data_json['touser']))
            self.send(text_data=json.dumps({
                "response_type": "user_status_by_id",
                "users": contactUsers.data}))
        elif command == "remove_contact":
            userid = text_data_json['user']
            contact = Contact.objects.get(
                user=self.scope['user'].pk, touser=userid)
            contact.is_deleted = True
            contact.deleted_last = datetime.utcnow()
            contact.save()
            self.send(text_data=json.dumps({
                "response_type": "remove_contact",
                "touser": userid,
            }))
        elif command == "message_seen":
            message_ids = text_data_json['message_ids']
            for id in message_ids:
                try:
                    message = Message.objects.get(pk=id)
                    if message.touser.pk == self.scope['user'].pk:
                        message.seen_by_to_user = True
                        message.save()

                        async_to_sync(self.channel_layer.group_send)(
                            str(message.fromuser.pk),
                            {
                                'type': 'message_seen_to_other_group',
                                'message': MessageSerializer(message).data,
                            }
                        )
                except Message.DoesNotExist:
                    pass
        elif command == "search":
            pass
        elif command == "add_contact":
            pass
        else:
            pass

    def message_seen_to_other_group(self, event):
        self.send(text_data=json.dumps({
            "response_type": "message_seen",
            "contactuser": event['message']['touser'],
            "message_id": event['message']['id']}))

    def send_message_to_other_group(self, event):
        self.send(text_data=json.dumps({
            "response_type": "new_message",
            "sent_by": event['sent_by'],
            "new_message": event['message']}))

    def disconnect(self, code):
        if hasattr(self, "group_name"):
            discardGroupFromChannellayer(self.group_name, self.channel_name)
        try:
            userStatus = UserStatus.objects.get(user=self.scope['user'])
            self.userStatus.online -= 1
            self.userStatus.lastseen = datetime.utcnow()
            self.userStatus.save()
        except:
            pass
        self.close()
