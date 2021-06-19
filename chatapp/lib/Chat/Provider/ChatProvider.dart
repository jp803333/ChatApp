import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:chatapp/Chat/Models/Contact.dart';
import 'package:chatapp/Chat/Models/Message.dart';
import 'package:chatapp/Common/Preferences.dart';
import 'package:flutter/widgets.dart';
import 'package:web_socket_channel/io.dart';

class ChatProvider extends ChangeNotifier {
  IOWebSocketChannel? channel;
  Stream? readStream;
  List<Contact> contacts = [];
  Timer? statusTimer;
  ChatProvider() {
    Preferences.getAuthToken().then((value) {
      this.channel = IOWebSocketChannel.connect(
        // "ws://10.0.2.2:8000/ws/chat/",
        "ws://192.168.1.74:8000/ws/chat/",
        headers: {"Authorization": 'Token $value'},
      );
      notifyListeners();
      readStream = this.channel?.stream.asBroadcastStream();
      readStream?.listen((event) {
        event = json.decode(event);
        print(event);
        switch (event['response_type']) {
          case "all_chats":
            contacts = List<Contact>.from(
                event['contacts']?.map((x) => Contact.fromMap(x)));
            for (Contact contact in contacts)
              contact.messages
                  .sort((a, b) => a.createdAt.compareTo(b.createdAt));
            notifyListeners();
            break;
          case "new_message":
            Message message = Message.fromMap(event["new_message"]);
            if (event['sent_by'] == "self") {
              Contact contact = contacts
                  .where((contact) => contact.touser.id == message.touser)
                  .first;
              contact.messages.add(message);
              contact.isDeleted = false;
            } else {
              if (contacts
                      .where((contact) => contact.touser.id == message.fromuser)
                      .length !=
                  0) {
                Contact contact = contacts
                    .where((contact) => contact.touser.id == message.fromuser)
                    .first;
                contact.isDeleted = false;
                contact.messages.add(message);
              } else {
                Contact contact = Contact(
                    id: event['sent_by']['id'],
                    isDeleted: event['sent_by']['is_deleted'],
                    deletedLast:
                        DateTime.parse(event['sent_by']['deleted_last']),
                    touser: ToUser.fromMap(event['sent_by']['touser']),
                    messages: [Message.fromMap(event['new_message'])]);
                contacts.add(contact);
                notifyListeners();
              }
            }
            notifyListeners();
            break;
          case "user_status_by_id":
            ToUser user = ToUser.fromMap(event["users"]);
            List<Contact> contact = contacts
                .where((element) => element.touser.id == user.id)
                .toList();
            if (contact.length != 0) {
              contact.first.touser.status.online = user.status.online;
              contact.first.touser.status.lastSeen = user.status.lastSeen;
            }
            notifyListeners();
            break;
          case "message_seen":
            contacts
                .where((contact) => contact.touser.id == event['contactuser'])
                .first
                .messages
                .where((message) => message.id == event['message_id'])
                .first
                .seen = true;
            notifyListeners();
            break;
          case "remove_contact":
            Contact contact = contacts
                .where((contact) => contact.touser.id == event['touser'])
                .first;
            contact.isDeleted = true;
            contact.deletedLast = DateTime.now();
            contact.messages = [];
            notifyListeners();
            break;
          default:
        }
      });
      this.statusTimer = Timer.periodic(Duration(seconds: 15), (_) {
        try {
          this.channel?.sink.add(json.encode({
                "command": "user_status",
              }));
        } catch (e) {
          log(e.toString());
        }
      });
    });
  }

  void sendMessage(int toUser, String message) {
    this.channel?.sink.add(json.encode({
          "command": "send_message",
          "touser": toUser,
          "message": message,
        }));
  }

  void deleteChat(String id) {
    this.channel?.sink.add(json.encode({
          "command": "remove_contact",
          "user": id,
        }));
  }

  @override
  void dispose() {
    this.statusTimer?.cancel();
    this.channel?.sink.close();

    super.dispose();
  }
}
