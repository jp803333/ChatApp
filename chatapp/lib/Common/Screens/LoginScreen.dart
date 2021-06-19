
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:chatapp/Common/Preferences.dart';
import 'package:chatapp/Common/Screens/TempScreen.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController username = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              child: Text(
                "Login",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24),
              ),
            ),
            Container(
              width: double.infinity,
              height: 200,
              padding: EdgeInsets.all(20),
              child: TextField(
                controller: username,
                decoration: InputDecoration(hintText: "Username"),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              child: Center(
                child: ElevatedButton(
                    onPressed: username.text.trim() == ''
                        ? null
                        : () async {
                            http.Response res = await http.post(
                                Uri.parse(
                                    // "http://10.0.2.2:8000/accounts/login/"),
                                    "http://192.168.1.74:8000/accounts/login/"),
                                body: {"username": username.text.trim()});
                            if (res.statusCode == 200) {
                              Preferences.setAuthToken(
                                  token: json
                                      .decode(res.body)['token']
                                      .toString());
                              Navigator.of(context)
                                  .pushReplacement(MaterialPageRoute(
                                builder: (context) => TempScreen(),
                              ));
                              // print(res.body.toString());
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Unable to login")));
                              // print(res.body);
                            }
                          },
                    child: Text("Login")),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
