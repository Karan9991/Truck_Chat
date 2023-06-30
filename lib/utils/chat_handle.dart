import 'package:chat/utils/shared_pref.dart';
import 'package:flutter/material.dart';

class ChatHandle {
  static void showChatHandle(BuildContext context) {
    TextEditingController _textEditingController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chat Handle'),
          content: TextField(
            controller: _textEditingController,
            decoration: InputDecoration(hintText: 'Enter your chat handle'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () async {
                String chatHandle = _textEditingController.text;
                await SharedPrefs.setString('chatHandle', chatHandle);
                Navigator.pop(context); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
}
