import 'package:chatapp/Chat/Screens/AllChat.dart';
import 'package:chatapp/Common/Preferences.dart';
import 'package:chatapp/Common/Screens/AddContactScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TempScreen extends StatefulWidget {
  const TempScreen({Key? key}) : super(key: key);

  @override
  _TempScreenState createState() => _TempScreenState();
}

class _TempScreenState extends State<TempScreen> {
  TextEditingController addcontact = TextEditingController();

  @override
  void dispose() {
    addcontact.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AllChat(),
                          ),
                        ),
                    child: Text('All Chat')),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Container(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                      controller: addcontact,
                      onChanged: (value) {
                        setState(() {});
                      },
                    )),
                    ElevatedButton(
                        onPressed: addcontact.text.trim() == ''
                            ? null
                            : () async {
                                var token = await Preferences.getAuthToken();
                                http.Response res = await http.post(
                                    Uri.parse(
                                        // 'http://10.0.2.2:8000/addcontact/'),
                                        'http://192.168.1.74:8000/addcontact/'),
                                    body: {
                                      "username": addcontact.text.trim(),
                                    },
                                    headers: {
                                      "Authorization": "Token $token"
                                    });
                                if (res.statusCode == 200) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Contact added"),
                                    ),
                                  );
                                  addcontact.clear();
                                  setState(() {});
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Error"),
                                    ),
                                  );
                                }
                              },
                        child: Text("Add this Contact"))
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AddContactScreen(),
                          ),
                        ),
                    child: Text('Add new contact')),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
