import 'dart:convert';

import 'package:chatapp/Common/Preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddContactScreen extends StatefulWidget {
  const AddContactScreen({Key? key}) : super(key: key);

  @override
  _AddContactScreenState createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  TextEditingController search = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: search,
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                  ElevatedButton(
                      onPressed: search.text.trim() == ""
                          ? null
                          : () async {
                              var token = await Preferences.getAuthToken();
                              http.Response res = await http.post(
                                  Uri.parse("http://192.168.1.74:8000/search/"),
                                  // Uri.parse("http://10.0.2.2:8000/search/"),
                                  body: {"keyword": search.text.trim()},
                                  headers: {"Authorization": "Token $token"});
                              print(json.decode(res.body));
                            },
                      child: Text('Search'))
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 0,
                itemBuilder: (context, index) => Container(
                  child: Row(),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
