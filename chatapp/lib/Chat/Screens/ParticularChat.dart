import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:chatapp/Chat/Models/Contact.dart';
import 'package:chatapp/Chat/Provider/ChatProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ParticularChat extends StatefulWidget {
  final ChatProvider chatProvider;
  final Contact contact;
  const ParticularChat(
      {Key? key, required this.chatProvider, required this.contact})
      : super(key: key);

  @override
  _ParticularChatState createState() => _ParticularChatState();
}

class _ParticularChatState extends State<ParticularChat> {
  TextEditingController message = TextEditingController();
  Timer? statusTimer;
  @override
  void initState() {
    this.statusTimer = Timer.periodic(Duration(seconds: 15), (_) {
      try {
        widget.chatProvider.channel?.sink.add(json.encode({
          "command": "user_status_by_id",
          "touser": widget.contact.touser.id
        }));
      } catch (e) {
        log(e.toString());
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    message.dispose();
    this.statusTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return ChangeNotifierProvider<ChatProvider>.value(
      value: widget.chatProvider,
      child: Consumer<ChatProvider>(
        builder: (context, model, child) => SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.contact.touser.username),
                  widget.contact.touser.status.online
                      ? Text("Online")
                      : Text(
                          widget.contact.touser.status.lastSeen.toString(),
                          style: TextStyle(fontSize: 12),
                        )
                ],
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    itemCount: widget.contact.messages.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: double.infinity,
                        margin: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: widget.contact.touser.id ==
                                  widget
                                      .contact
                                      .messages[widget.contact.messages.length -
                                          index -
                                          1]
                                      .touser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Container(
                              constraints:
                                  BoxConstraints(maxWidth: width * 0.8),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: widget.contact.touser.id ==
                                          widget
                                              .contact
                                              .messages[widget
                                                      .contact.messages.length -
                                                  index -
                                                  1]
                                              .touser
                                      ? Colors.red.shade200
                                      : Colors.green.shade200),
                              child: Text(
                                widget
                                    .contact
                                    .messages[widget.contact.messages.length -
                                        index -
                                        1]
                                    .message
                                    .toString(),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  // height: height * 0.2,
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                          child: TextField(
                        controller: message,
                        onChanged: (value) {
                          setState(() {});
                        },
                      )),
                      ElevatedButton(
                          onPressed: message.text.trim() == ''
                              ? null
                              : () {
                                  model.sendMessage(widget.contact.touser.id,
                                      message.text.trim());
                                  message.clear();
                                },
                          child: Icon(Icons.send))
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
