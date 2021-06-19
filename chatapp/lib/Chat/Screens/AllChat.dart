import 'package:chatapp/Chat/Provider/ChatProvider.dart';
import 'package:chatapp/Chat/Screens/ParticularChat.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllChat extends StatefulWidget {
  const AllChat({Key? key}) : super(key: key);

  @override
  _AllChatState createState() => _AllChatState();
}

class _AllChatState extends State<AllChat> {
  ChatProvider chatProvider = ChatProvider();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    chatProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChatProvider>.value(
      value: chatProvider,
      child: Consumer<ChatProvider>(
        builder: (context, model, child) {
          if (model.channel == null)
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          else
            return Scaffold(
              backgroundColor: Colors.grey.shade200,
              appBar: AppBar(),
              body: Center(
                child: ListView.builder(
                  itemCount: model.contacts.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ParticularChat(
                            chatProvider: chatProvider,
                            contact: model.contacts[index],
                          ),
                        ));
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        margin: EdgeInsets.all(10),
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white),
                        child: Text(
                          model.contacts[index].touser.username,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xffa5a5a5),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
        },
      ),
    );
  }
}
