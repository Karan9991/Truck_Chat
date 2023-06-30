// import 'dart:html';

import 'package:chat/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_6.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chat/get_all_reply_messages.dart';

class Chat extends StatefulWidget {
  final String topic;
  //  final List<ReplyMsg> replyMsgs;
  final String serverMsgId;

  Chat({
    required this.topic,
    //  required this.replyMsgs,
    required this.serverMsgId,
  });

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  TextEditingController messageController = TextEditingController();
  List<ReplyMsg> filteredReplyMsgs = [];
  List<ReplyMsgg> sentMessages = [];
  int rid = 0;
  String emoji_id = '';
  int timestam = 0;
  String status_message = '';
  int statusCode = 0;
  List<ReplyMsg> replyMsgs = [];
  bool sendingMessage = false; // Added variable to track sending state
  String? shareprefuserId = SharedPrefs.getString('userId');
  int userId = 0;
  double? storedLatitude = 1.0;
  double? storedLongitude = 1.0;
  @override
  void initState() {
    super.initState();

    userId = int.parse(shareprefuserId!);
     storedLatitude = SharedPrefs.getDouble('latitude');
     storedLongitude = SharedPrefs.getDouble('longitude');

    print('init state');
    getAllMessages(widget.serverMsgId);

    // filterReplyMsgs();
  }

  void filterReplyMsgs() {
    print('reply messges in fliter replymsf');
    print(replyMsgs);
    filteredReplyMsgs =
        replyMsgs.where((reply) => reply.topic == widget.topic).toList();
  }

  Future<bool> sendMessage(
    String message,
    String serverMsgId,
    int userId,
    String emojiId,
  ) async {
    setState(() {
      sendingMessage = true; // Set sending state to true
    });

    print('send message');
    print('message $message');
    print('sermsgid $serverMsgId');
    print('userid $userId');
    print('emojiid $emoji_id');

    //  int servermsgid = int.parse(serverMsgId);
    final url =
        'http://smarttruckroute.com/bb/v1/device_post_message'; // Replace with your API endpoint
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'message': message,
      'server_msg_id': serverMsgId,
      'user_id': userId,
      'latitude': storedLatitude,
      'longitude': storedLongitude,
      'emoji_id': emojiId,
    });

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      print(response.body);

      if (response.statusCode == 200) {
        setState(() {
          sendingMessage = false; // Set sending state to false
        });

        final jsonResult = jsonDecode(response.body);
        int statusCode = jsonResult['status'] as int;
        print('status code $statusCode');

        if (jsonResult.containsKey('message')) {
          String status_message = jsonResult['message'] as String;
          print('status_message $status_message');

          // Add the sent message to the list
          sentMessages.add(ReplyMsgg(serverMsgId, userId, message,
              DateTime.now().millisecondsSinceEpoch));
        } else {
          String status_message = '';
        }

        return true;
      } else {
        setState(() {
          sendingMessage = false; // Set sending state to false
        });
        status_message = 'Error: ${response.statusCode}';
      }
    } catch (e) {
      status_message = e.toString();
      setState(() {
        sendingMessage = false; // Set sending state to false
      });
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 8),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.blue[300],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                widget.topic,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredReplyMsgs.length + sentMessages.length,
              itemBuilder: (context, index) {
                if (index < filteredReplyMsgs.length) {
                  final reply = filteredReplyMsgs[index];
                  final replyMsg = reply.replyMsg;
                  final timestampp = reply.timestamp;

                  DateTime dateTime =
                      DateTime.fromMillisecondsSinceEpoch(timestampp);
                  String formattedDateTime =
                      DateFormat('MMM d, yyyy h:mm:ss a').format(dateTime);
                  final timestamp = formattedDateTime;

                  rid = reply.rid;
                  emoji_id = reply.emojiId;
                  timestam = timestampp;

                  bool isCurrentUser = reply.uid ==
                      userId; // Check if the user_id is equal to 69979

                  return Padding(
                    padding: EdgeInsets.all(8.0),
                    child: ChatBubble(
                      clipper: ChatBubbleClipper6(
                          type: isCurrentUser
                              ? BubbleType.sendBubble
                              : BubbleType.receiverBubble),
                      alignment: isCurrentUser
                          ? Alignment.topRight
                          : Alignment.topLeft,
                      margin: EdgeInsets.only(bottom: 16.0),
                      backGroundColor: Colors.blue[300],
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 250.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              replyMsg,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20),
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              timestamp,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  final sentIndex = index - filteredReplyMsgs.length;
                  final sentMessage = sentMessages[sentIndex];
                  final timestampp = sentMessage.timestamp;

                  DateTime dateTime =
                      DateTime.fromMillisecondsSinceEpoch(timestampp);
                  String formattedDateTime =
                      DateFormat('MMM d, yyyy h:mm:ss a').format(dateTime);
                  final timestamp = formattedDateTime;

                  bool isCurrentUser = sentMessage.uid ==
                      userId; // Check if the user_id is equal to 69979

                  return Padding(
                    padding: EdgeInsets.all(8.0),
                    child: ChatBubble(
                      clipper: ChatBubbleClipper6(
                          type: isCurrentUser
                              ? BubbleType.sendBubble
                              : BubbleType.receiverBubble),
                      alignment: isCurrentUser
                          ? Alignment.topRight
                          : Alignment.topLeft,
                      margin: EdgeInsets.only(bottom: 16.0),
                      backGroundColor: Colors.blue[300],
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 250.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sentMessage.replyMsg,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20),
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              timestamp,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(24.0),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Compose message',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                FloatingActionButton(
                  onPressed: () async {
                    bool messageSent = await sendMessage(
                      messageController.text,
                      widget.serverMsgId,
                      userId,
                      emoji_id,
                    );
                    if (messageSent) {
                      print('message send');
                      // Message sent successfully, handle any UI updates if needed
                    } else {
                      print('message failed not sent');
                      // Failed to send the message, handle any UI updates if needed
                    }
                    setState(() {
                      messageController.clear();
                    });
                  },
                  backgroundColor: Colors.blue,
                  child: sendingMessage // Check sending state
                      ? CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ) // Show progress indicator
                      : Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> getAllMessages(dynamic conversationId) async {
    print('Conversation Id  $conversationId');
    int statusCode = 0;
    String counts = '';

    String statusMessage = '';

    final url =
        Uri.parse("http://smarttruckroute.com/bb/v1/get_all_reply_message");

    Map<String, dynamic> requestBody = {
      "server_message_id": conversationId,
    };

    try {
      http.Response response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        print('200');
        final result = response.body;

        try {
          final jsonResult = jsonDecode(result);

          counts = jsonResult['counts'];

          final jsonReplyList = jsonResult['messsage_reply_list'];

          print('jsonreplylist');
          print(jsonReplyList);

          int countValue = int.parse(counts);

          print(jsonReplyList.length);

          //if (counts == jsonReplyList.length) {
          for (var i = 0; i < countValue; ++i) {
            final jsonReply = jsonReplyList[i];
            final rid = jsonReply['server_msg_reply_id'];
            final replyMsg = jsonReply['reply_msg'];
            final uid = jsonReply['user_id'];
            final emojiId = jsonReply['emoji_id'];

            print("server_msg_reply_id  $rid");
            print("reply_msg $replyMsg");
            print("user id  $uid");
            print("emoji_id $emojiId");
            int timestamp;
            try {
              //  timestamp = int.tryParse(jsonReply['timestamp']) ?? 0;
              timestamp = jsonReply['timestamp'] ?? 0;
              print('try in for $timestamp');
            } catch (e) {
              timestamp = 0;
              print('catch $timestamp');
            }

            replyMsgs.add(
                ReplyMsg(rid, uid, replyMsg, timestamp, emojiId, widget.topic));
          }
          // } else {
          //   print('elsee');
          // }

          setState(() {
            // Update the conversation data
            // conversationTopics.add(conversationTopic);
            // conversationTimestamps.add(conversationTimestamp);
            // replyCounts.add(counts);
            this.replyMsgs = replyMsgs;

            filterReplyMsgs();
          });
        } catch (e) {
          print('catch 2 $e');
          statusMessage = e.toString();
        }
      } else {
        statusMessage = 'Connection Error';
      }
    } catch (e) {
      print('catch 1 $e');
    }
    //  }

    return false;
  }
}
