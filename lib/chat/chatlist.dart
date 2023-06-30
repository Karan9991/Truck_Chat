import 'package:chat/chat/chat.dart';
import 'package:chat/chat/new_conversation.dart';
import 'package:chat/chats_screen.dart';
import 'package:chat/settings/settings.dart';
import 'package:chat/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:chat/get_all_reply_messages.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:chat/home_screen.dart';

class ChatList extends StatefulWidget {
  final Key key;

  ChatList({required this.key});

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  List<String> conversationTopics = [];
  // List<int> conversationTimestamps = [];
  List<int> conversationTimestamps = [];

  List<String> replyCounts = [];
  List<ReplyMsg> replyMsgs = [];

  // final String userId = "69979";
  // final double latitude = 1.0;
  // final double longitude = 1.0;

  List<String> serverMsgIds = [];
  int statusCode = 0;
  String statusMessage = '';

  @override
  void initState() {
    super.initState();
    runNow();
  }

  void onGetPreviousMessagesResult(
    bool success,
    int statusCode,
    String statusMessage,
    List<String> serverMsgIds,
  ) {
    if (success) {
      setState(() {
        // Update the conversation data
        this.serverMsgIds = serverMsgIds;
      });
      getAllMessages(serverMsgIds);
      // print("Messages: $serverMsgIds");
      // print("Status Code: $statusCode");
      // print("Status Message: $statusMessage");
    } else {
      // Handle the error
      print("Error: $statusMessage");
    }
    // Implement your logic here after getting previous messages
  }

  Future<void> runNow() async {
    String? userId = SharedPrefs.getString('userId');
    double? storedLatitude = SharedPrefs.getDouble('latitude');
    double? storedLongitude = SharedPrefs.getDouble('longitude');

    Uri url =
        Uri.parse("http://smarttruckroute.com/bb/v1/get_previous_messages");
    Map<String, dynamic> requestBody = {
      "user_id": userId,
      "latitude": storedLatitude.toString(),
      "longitude": storedLongitude.toString(),
    };

    try {
      http.Response response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        print("chat list response body");
        print(response.body);
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        statusCode = jsonResponse['status'];
        if (jsonResponse.containsKey('message')) {
          statusMessage = jsonResponse['message'];
        } else {
          statusMessage = '';
        }

        dynamic conversationId = jsonResponse['server_msg_id'];
        print('Conversation Id $conversationId');

        List<dynamic> serverMsgIds = jsonResponse['server_msg_id'];
        List<String> serverMsgIdsList =
            List<String>.from(serverMsgIds.map((e) => e.toString()));

        setState(() {
          // Update the conversation data
          this.serverMsgIds = serverMsgIdsList;
        });

        onGetPreviousMessagesResult(
            true, statusCode, statusMessage, serverMsgIdsList);
      } else {
        statusMessage = 'Connection Error';
        onGetPreviousMessagesResult(
            false, statusCode, statusMessage, serverMsgIds);
      }
    } catch (e) {
      statusMessage = e.toString();
      onGetPreviousMessagesResult(
          false, statusCode, statusMessage, serverMsgIds);
    }
  }

  Future<bool> getAllMessages(List<String> serverMessageIds) async {
    print('list  $serverMessageIds');
    int statusCode = 0;
    String counts = '';
    int conversationTimestamp = 0;
    List<ReplyMsg> replyMsgs = [];

    String statusMessage = '';
    String conversationTopic = '';

    final url =
        Uri.parse("http://smarttruckroute.com/bb/v1/get_all_reply_message");

    for (var serverMessageId in serverMessageIds) {
      Map<String, dynamic> requestBody = {
        "server_message_id": serverMessageId,
      };

      try {
        http.Response response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(requestBody),
        );
        if (response.statusCode == 200) {
          final result = response.body;

          try {
            final jsonResult = jsonDecode(result);

            if (jsonResult.containsKey('message')) {
              statusMessage = jsonResult['message'];
            } else {
              statusMessage = '';
            }

            counts = jsonResult['counts'];

            conversationTopic = jsonResult['original'];
            print("Conversation Topic $conversationTopic");
            print('Reply Counts $counts');
            try {
              // conversationTimestamp =
              //     int.tryParse(jsonResult['timestamp']) ?? 0;
              conversationTimestamp = jsonResult['timestamp'] ?? 0;

              print('Timestamps $conversationTimestamps');
            } catch (e) {
              print('catch $e');
              conversationTimestamp = 0;
            }

            // final jsonReplyList = jsonResult['messsage_reply_list'];
            // int countValue = int.parse(counts);

            // print(jsonReplyList.length);

            //if (counts == jsonReplyList.length) {
            // print('iff');
            // for (var i = 0; i < countValue; ++i) {
            //   final jsonReply = jsonReplyList[i];
            //   final rid = jsonReply['server_msg_reply_id'];
            //   final replyMsg = jsonReply['reply_msg'];
            //   final uid = jsonReply['user_id'];
            //   final emojiId = jsonReply['emoji_id'];

            //   print("server_msg_reply_id  $rid");
            //   print("reply_msg $replyMsg");
            //   print("user id  $uid");
            //   print("emoji_id $emojiId");
            //   int timestamp;
            //   try {
            //     //  timestamp = int.tryParse(jsonReply['timestamp']) ?? 0;
            //     timestamp = jsonReply['timestamp'] ?? 0;
            //     print('try in for $timestamp');
            //   } catch (e) {
            //     timestamp = 0;
            //     print('catch $timestamp');
            //   }

            //   replyMsgs.add(ReplyMsg(
            //       rid, uid, replyMsg, timestamp, emojiId, conversationTopic));
            // }

            // } else {
            //   print('elsee');
            // }

            setState(() {
              // Update the conversation data
              conversationTopics.add(conversationTopic);
              conversationTimestamps.add(conversationTimestamp);
              //getAllMessages(serverMessageIds);
              // serverMsgIds.add(serverMessageIds);
              replyCounts.add(counts);
              this.replyMsgs = replyMsgs;
            });
          } catch (e) {
            print(e);
            statusMessage = e.toString();
          }
        } else {
          statusMessage = 'Connection Error';
        }
      } catch (e) {
        print(e);
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: ListView.builder(
        itemCount: conversationTopics.length,
        itemBuilder: (context, index) {
          final topic = conversationTopics[index];
          final timestampp = conversationTimestamps[index];
          final count = replyCounts[index];
          final serverMsgID = serverMsgIds[index];

          // print('sssserver message id  $serverMsgID');

          DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestampp);
          String formattedDateTime =
              DateFormat('MMM d, yyyy h:mm:ss a').format(dateTime);
          final timestamp = formattedDateTime;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Chat(
                    topic: topic,
                    // replyMsgs: replyMsgs,
                    serverMsgId: serverMsgID,
                  ),
                ),
              );
            },
            child: Card(
              elevation: 2,
              color: Colors.blue[300],
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(
                  topic,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 5, top: 8),
                      child: Text(
                        'Last Active: $timestamp',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 5),
                      child: Text(
                        'Replies: $count',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
