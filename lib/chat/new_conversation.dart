import 'package:chat/chat/chatlist.dart';
import 'package:chat/home_screen.dart';
import 'package:chat/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chat/utils/lat_lng.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class NewConversationScreen extends StatefulWidget {
  @override
  _NewConversationScreenState createState() => _NewConversationScreenState();
}

class _NewConversationScreenState extends State<NewConversationScreen> {
  String status_message = '';
  int status_code = 0;
  int conversation_id = 0;
  TextEditingController _textEditingController = TextEditingController();

  bool _isSending = false;
  
  stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  String _typedText = '';

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
            IconButton(
              icon: Icon(Icons.mic),
              onPressed: () {
                _toggleListening();
              },
            ),
            SizedBox(width: 8.0),
            Expanded(
              child: TextField(
                controller: _textEditingController,
                onChanged: (value) {
                  _typedText = value;
                },
                decoration: InputDecoration(
                  hintText: 'Compose a new conversation',
                ),
              ),
            ),
            SizedBox(width: 8.0),
            ElevatedButton(
              onPressed: () async {
                await _sendConversation();
              },
              child: _isSending
                  ? CircularProgressIndicator() 
                  : Icon(Icons.send),
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

  Future<void> _sendConversation() async {
    setState(() {
      _isSending = true; // Start sending, show progress indicator
    });

    bool sent = await send();

    if (sent) {
      // Navigation to chat screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }

    setState(() {
      _isSending = false; 
    });
  }

  void _toggleListening() {
    _startListening();
  }

  void _startListening() async {
    bool available = await _speechToText.initialize();
    if (available) {
      _speechToText.listen(
        onResult: (result) {
          setState(() {
            _textEditingController.text = result.recognizedWords;
            _typedText = result.recognizedWords;
          });
        },
        listenMode: stt.ListenMode.dictation,
        pauseFor: Duration(seconds: 2),
      );
      setState(() {
        _isListening = true;
      });
    }
  }

  void _stopListening() {
    _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }
}
