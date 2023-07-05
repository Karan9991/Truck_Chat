import 'package:chat/chat/new_conversation.dart';
import 'package:chat/chats_screen.dart';
import 'package:chat/reactivechat/chatreact.dart';
import 'package:chat/settings/settings.dart';
import 'package:chat/utils/shared_pref.dart';
import 'package:chat/get_all_reply_messages.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chat/home_screen.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class ChatListr extends StatefulWidget {
  final Key key;

  ChatListr({
    required this.key,
  });

  @override
  _ChatListrState createState() => _ChatListrState();
}

class _ChatListrState extends State<ChatListr> {
  List<String> conversationTopics = [];
  List<int> conversationTimestamps = [];

  List<String> replyCounts = [];
  List<ReplyMsg> replyMsgs = [];

  int statusCode = 0;
  String statusMessage = '';
  List<String> serverMsgIds = [];

  Timer? conversationTimer;

  @override
  void initState() {
    super.initState();

    getData();
  }

  @override
  void dispose() {
    super.dispose();
    conversationTimer?.cancel();
  }

  Future<void> getData() async {
    await getConversationsData();

    conversationTimer = Timer.periodic(Duration(seconds: 10), (_) async {
      // Clear the previous conversation data
      print('Timer');
      conversationTopics.clear();
      conversationTimestamps.clear();
      replyCounts.clear();

      await getConversationsData();
    });
  }

  Future<void> getConversationsData() async {
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
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        List<dynamic> serverMsgIds = jsonResponse['server_msg_id'];
        List<String> serverMsgIdsList =
            List<String>.from(serverMsgIds.map((e) => e.toString()));

        this.serverMsgIds = serverMsgIdsList;

        int statusCode = 0;
        String counts = '';
        int conversationTimestamp = 0;
        List<ReplyMsg> replyMsgs = [];
        String statusMessage = '';
        String conversationTopic = '';

        final url =
            Uri.parse("http://smarttruckroute.com/bb/v1/get_all_reply_message");

        for (var serverMessageId in serverMsgIdsList) {
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

                counts = jsonResult['counts'];
                conversationTopic = jsonResult['original'];
                conversationTimestamp = jsonResult['timestamp'] ?? 0;

                 // setState(() {
                conversationTopics.add(conversationTopic);
                conversationTimestamps.add(conversationTimestamp);

                replyCounts.add(counts);
               // this.replyMsgs = replyMsgs;
               //  });
              } catch (e) {
                // Handle JSON decoding error
              }
            } else {
              // Handle connection error
            }
          } catch (e) {
            // Handle exception
          }
        }
        setState(() {
   
      });
      } else {
        // Handle connection error
      }
      
    } catch (e) {
      // Handle exception
    }
  }

  // void onGetConversationsIds(
  //   bool success,
  //   int statusCode,
  //   String statusMessage,
  //   List<String> serverMsgIds,
  // ) {
  //   if (success) {
  //     setState(() {
  //       // Update the conversation data
  //       this.serverMsgIds = serverMsgIds;
  //     });
  //     // getConversationsList(serverMsgIds);

  //     // print("Messages: $serverMsgIds");
  //     // print("Status Code: $statusCode");
  //     // print("Status Message: $statusMessage");
  //   } else {
  //     // Handle the error
  //     print("Error: $statusMessage");
  //   }
  //   // Implement your logic here after getting previous messages
  // }

  Future<void> getConversationsIds() async {
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
        // print("chat list response body");
        // print(response.body);
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // statusCode = jsonResponse['status'];
        // if (jsonResponse.containsKey('message')) {
        //   statusMessage = jsonResponse['message'];
        // } else {
        //   statusMessage = '';
        // }

        //  dynamic conversationId = jsonResponse['server_msg_id'];
        // print('Conversation Id $conversationId');

        List<dynamic> serverMsgIds = jsonResponse['server_msg_id'];
        List<String> serverMsgIdsList =
            List<String>.from(serverMsgIds.map((e) => e.toString()));

        setState(() {
          // Update the conversation data

          this.serverMsgIds = serverMsgIdsList;
        });

        await getConversationsList(serverMsgIdsList);

        // onGetConversationsIds(
        //     true, statusCode, statusMessage, serverMsgIdsList);
      } else {
        // statusMessage = 'Connection Error';
        // onGetConversationsIds(false, statusCode, statusMessage, serverMsgIds);
      }
    } catch (e) {
      // statusMessage = e.toString();
      // onGetConversationsIds(false, statusCode, statusMessage, serverMsgIds);
    }
  }

  Future<bool> getConversationsList(List<String> serverMessageIds) async {
    //print('list  $serverMessageIds');
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

            // if (jsonResult.containsKey('message')) {
            //   statusMessage = jsonResult['message'];
            // } else {
            //   statusMessage = '';
            // }

            counts = jsonResult['counts'];

            conversationTopic = jsonResult['original'];
            // print("Conversation Topic $conversationTopic");
            // print('Reply Counts $counts');
            // try {
            // conversationTimestamp =
            //     int.tryParse(jsonResult['timestamp']) ?? 0;
            conversationTimestamp = jsonResult['timestamp'] ?? 0;

            // print('Timestamps $conversationTimestamps');
            //  } catch (e) {
            // print('catch $e');
            conversationTimestamp = 0;
            // }

            setState(() {
              conversationTopics.add(conversationTopic);
              conversationTimestamps.add(conversationTimestamp);

              replyCounts.add(counts);
              this.replyMsgs = replyMsgs;
            });
          } catch (e) {
            // print(e);
            //statusMessage = e.toString();
          }
        } else {
          // statusMessage = 'Connection Error';
        }
      } catch (e) {
        // print(e);
      }
    }

    return false;
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: null,
  //     body: conversationTopics.isEmpty
  //         ? Center(
  //             child: CircularProgressIndicator(),
  //           )
  //         : ListView.builder(
  //             itemCount: conversationTopics.length,
  //             itemBuilder: (context, index) {
  //               final topic = conversationTopics[index];
  //               final timestampp = conversationTimestamps[index];
  //               final count = replyCounts[index];
  //               final serverMsgID = serverMsgIds[index];

  //               DateTime dateTime =
  //                   DateTime.fromMillisecondsSinceEpoch(timestampp);
  //               String formattedDateTime =
  //                   DateFormat('MMM d, yyyy h:mm:ss a').format(dateTime);
  //               final timestamp = formattedDateTime;

  //               return GestureDetector(
  //                 onTap: () {
  //                   Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                       builder: (context) => Chat(
  //                         topic: topic,
  //                         serverMsgId: serverMsgID,
  //                       ),
  //                     ),
  //                   );
  //                 },
  //                 child: Card(
  //                   elevation: 2,
  //                   color: Colors.blue[300],
  //                   margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //                   child: ListTile(
  //                     title: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Row(
  //                           children: [
  //                             Icon(
  //                               Icons.chat,
  //                               size: 17,
  //                             ),
  //                             SizedBox(width: 8),
  //                           ],
  //                         ),
  //                         Text(
  //                           topic,
  //                           style: TextStyle(
  //                             fontSize: 18,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     subtitle: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Padding(
  //                           padding: EdgeInsets.only(bottom: 5, top: 8),
  //                           child: Text(
  //                             'Last Active: $timestamp',
  //                             style: TextStyle(fontSize: 14),
  //                           ),
  //                         ),
  //                         Padding(
  //                           padding: EdgeInsets.only(bottom: 5),
  //                           child: Text(
  //                             'Replies: $count',
  //                             style: TextStyle(fontSize: 14),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     trailing: Icon(
  //                       Icons.arrow_forward_ios,
  //                       color: Colors.white,
  //                     ),
  //                   ),
  //                 ),
  //               );
  //             },
  //           ),
  //   );
  // }

//original
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
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.chat,
                          size: 17,
                        ), // Replace with your chat icon
                        SizedBox(
                            width: 8), // Add spacing between icon and title
                        // Replace with your chat title
                      ],
                    ),
                    Text(
                      topic,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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

//news
  // @override
  // Widget build(BuildContext context) {
  //   return SingleChildScrollView(
  //     child: ListView.builder(
  //       shrinkWrap: true,
  //       physics: NeverScrollableScrollPhysics(),
  //       itemCount: conversationTopics.length,
  //       itemBuilder: (context, index) {

  //       final topic = conversationTopics[index];
  //         final timestampp = conversationTimestamps[index];
  //         final count = replyCounts[index];
  //         final serverMsgID = serverMsgIds[index];

  //         // print('sssserver message id  $serverMsgID');

  //         DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestampp);
  //         String formattedDateTime =
  //             DateFormat('MMM d, yyyy h:mm:ss a').format(dateTime);
  //         final timestamp = formattedDateTime;

  //         return Card(
  //           color: Colors.blue,
  //           elevation: 2,
  //           margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  //           child: InkWell(
  //             onTap: () {
  //   Navigator.push(
  //               context,
  //               MaterialPageRoute(
  //                 builder: (context) => Chat(
  //                   topic: topic,
  //                   serverMsgId: serverMsgID,
  //                 ),
  //               ),
  //             );              },
  //             child: Padding(
  //               padding: EdgeInsets.all(16),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Row(
  //                     children: [
  //                       Image.asset(
  //                         'assets/news.png',
  //                         width: 24,
  //                         height: 24,
  //                         color: Colors.black,
  //                       ),
  //                       SizedBox(width: 8),
  //                       Expanded(
  //                         // Wrap the Text widget with Expanded
  //                         child: Text(
  //                           topic,
  //                           style: TextStyle(
  //                               fontSize: 16,
  //                               fontWeight: FontWeight.bold,
  //                               color: Colors.white),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   SizedBox(height: 8),
  //                   Padding(
  //                     padding:
  //                         EdgeInsets.only(left: 32), // Adjust the left padding

  //                     child: Text(
  //                       'Posted on $timestamp',
  //                       style: TextStyle(
  //                         fontSize: 14,
  //                         color: Colors.black,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }
}
