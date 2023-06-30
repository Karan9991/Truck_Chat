import 'package:chat/chat/chatlist.dart';
import 'package:chat/home_screen.dart';
import 'package:chat/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chat/utils/lat_lng.dart';

class NewConversationScreen extends StatelessWidget {
  String status_message = '';
  int status_code = 0;
  int conversation_id = 0;
  TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Conversation'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.chat,
              size: 24.0,
            ),
            SizedBox(width: 8.0),
            Expanded(
              child: TextField(
                controller: _textEditingController,
                decoration: InputDecoration(
                  hintText: 'Compose a new conversation',
                ),
              ),
            ),
            SizedBox(width: 8.0),
            ElevatedButton(
                         onPressed: () async {
                bool sent = await send();
                if (sent) {
                  // Navigation to chat screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                }
              },

              child: Text('Send'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> send() async {
    String newConversation = _textEditingController.text;
    String? serialNumber = SharedPrefs.getString('serialNumber');
    Map<String, double> locationData = await getLocation();
    double latitude = locationData['latitude']!;
    double longitude = locationData['longitude']!;

    final Uri url =
        Uri.parse("http://smarttruckroute.com/bb/v1/device_message");

    try {
      Map<String, dynamic> entity = {
        "device_id": serialNumber,
        "message_device_type": "Android",
        "message": newConversation,
        "message_latitude": latitude.toString(),
        "message_longitude": longitude.toString(),
        "emoji_id": "0",
      };

      http.Response response = await http.post(
        url,
        body: json.encode(entity),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        String result = response.body;
        print('new conversation response body $result');
        // print('[REPLY] $result');

        Map<String, dynamic> jsonResult = json.decode(result);
        status_code = jsonResult['status'];
        print('new conversation status_code $status_code');

        if (jsonResult.containsKey('message')) {
          status_message = jsonResult['message'];
          print('new conversation status_message $status_message');
        } else {
          status_message = '';
        }

        if (jsonResult.containsKey('server_msg_id')) {
             conversation_id = jsonResult['server_msg_id'];
           print('new conversation id $conversation_id');
        }

        return true;
      } else {
        status_message = 'Connection Error';
      }
    } catch (e) {
      print('new conversation catch $e');
      status_message = e.toString();
    }

    return false;
  }
}
