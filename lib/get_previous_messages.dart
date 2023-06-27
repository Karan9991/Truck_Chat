// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';

// class GetPreviousMessagesAsyncTask {
//   final String userId;
//   final double latitude;
//   final double longitude;
//   final int? maxPosts;
//   final int? maxHours;

//   List<String> server_msg_id = [];
//   int status_code = 0;
//   String status_message = '';

//   GetPreviousMessagesAsyncTask(
//     this.userId,
//     this.latitude,
//     this.longitude, {
//     this.maxPosts,
//     this.maxHours,
//   });

//   void onGetPreviousMessagesResult(
//     bool success,
//     int status_code,
//     String status_message,
//     List<String> server_msg_id,
//   ) {
//     if (success) {
//       // Process the fetched messages

//       getAllMessages(server_msg_id);
//       print("Messages: $server_msg_id");
//       print("Status Code: $status_code");
//       print("Status Message: $status_message");
//     } else {
//       // Handle the error
//       print("Error: $status_message");
//     }
//     // Implement your logic here after getting previous messages
//   }

//   Future<void> runNow() async {
//     Uri url =
//         Uri.parse("http://smarttruckroute.com/bb/v1/get_previous_messages");
//     Map<String, dynamic> requestBody = {
//       "user_id": userId,
//       "latitude": latitude.toString(),
//       "longitude": longitude.toString(),
//       // Add other optional parameters if needed
//       "max_posts": maxPosts,
//       "max_hours": maxHours,
//     };

//     try {
//       http.Response response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(requestBody),
//       );

//       if (response.statusCode == 200) {
//         print("response body");
//         print(response.body);
//         Map<String, dynamic> jsonResponse = jsonDecode(response.body);
//         status_code = jsonResponse['status'];
//         if (jsonResponse.containsKey('message')) {
//           status_message = jsonResponse['message'];
//         } else {
//           status_message = '';
//         }

//         List<dynamic> serverMsgIds = jsonResponse['server_msg_id'];
//         server_msg_id =
//             List<String>.from(serverMsgIds.map((e) => e.toString()));

//         onGetPreviousMessagesResult(
//             true, status_code, status_message, server_msg_id);
//       } else {
//         status_message = 'Connection Error';
//         onGetPreviousMessagesResult(
//             false, status_code, status_message, server_msg_id);
//       }
//     } catch (e) {
//       status_message = e.toString();
//       onGetPreviousMessagesResult(
//           false, status_code, status_message, server_msg_id);
//     }
//   }

//   Future<bool> doInBackground() async {
//     await runNow();
//     return true;
//   }

//   Future<void> execute() async {
//     await doInBackground();
//   }

//   Future<bool> getAllMessages(List<String> serverMessageIds) async {
//     List<String> conversationTopics = [];
//     List<int> conversationTimestamps = [];
//     List<String> replyCounts = [];
//     List<ReplyMsg> replyMsgs = [];

//     print('list  $serverMessageIds');
//     int status_code = 0;
//     String counts = '';
//     int conversation_timestamp = 0;
//     //String conversation_timestamp = '';
//     List<ReplyMsg> reply_msgs = [];

//     String status_message = '';
//     String conversation_topic = '';

//     final url =
//         Uri.parse("http://smarttruckroute.com/bb/v1/get_all_reply_message");

//     for (var serverMessageId in serverMessageIds) {
//       Map<String, dynamic> requestBody = {
//         "server_message_id": serverMessageId,
//       };

//       // Map<String, dynamic> requestBody = {
//       //   "server_message_id": "48702",
//       // };

//       try {
//         http.Response response = await http.post(
//           url,
//           headers: {"Content-Type": "application/json"},
//           body: jsonEncode(requestBody),
//         );
//         if (response.statusCode == 200) {
//           final result = response.body;

//           try {
//             final jsonResult = jsonDecode(result);
//             // status_code = jsonResult[PARAM_STATUS];

//             if (jsonResult.containsKey('message')) {
//               status_message = jsonResult['message'];
//             } else {
//               status_message = '';
//             }

//             counts = jsonResult['counts'];

//             conversation_topic = jsonResult['original'];
//             print("conversation topic $conversation_topic");
//             print('counts $counts');
//             try {
//               conversation_timestamp =
//                   int.tryParse(jsonResult['timestamp']) ?? 0;
//             } catch (e) {
//               conversation_timestamp = 0;
//             }

//             final jsonReplyList = jsonResult['messsage_reply_list'];
//             int countValue = int.parse(counts);

//             if (counts == jsonReplyList.length) {
//               for (var i = 0; i < countValue; ++i) {
//                 final jsonReply = jsonReplyList[i];
//                 final rid = jsonReply['server_msg_reply_id'];
//                 final replyMsg = jsonReply['reply_msg'];
//                 final uid = jsonReply['user_id'];
//                 final emojiId = jsonReply['emoji_id'];
//                 int timestamp;
//                 try {
//                   timestamp = int.tryParse(jsonReply['timestamp']) ?? 0;
//                 } catch (e) {
//                   timestamp = 0;
//                 }

//                 reply_msgs
//                     .add(ReplyMsg(rid, uid, replyMsg, timestamp, emojiId));
//               }
//             }
//             conversationTopics.add(conversation_topic);
//             conversationTimestamps.add(conversation_timestamp);
//             replyCounts.add(counts);

//             // return true;
//           } catch (e) {
//             print(e);
//             status_message = e.toString();
//           }
//         } else {
//           status_message = 'Connection Error';
//         }
//       } catch (e) {
//         print(e);
//       }
//     }

//     return false;
//   }
// }

// class ReplyMsg {
//   final String rid;
//   final String uid;
//   final String replyMsg;
//   final int timestamp;
//   final String emojiId;

//   ReplyMsg(this.rid, this.uid, this.replyMsg, this.timestamp, this.emojiId);
// }

// class ChatListScreen extends StatelessWidget {
//   final List<String> conversationTopics;
//   final List<int> conversationTimestamps;
//   final List<String> replyCounts;
//   final List<ReplyMsg> replyMsgs;

//   ChatListScreen({
//     required this.conversationTopics,
//     required this.conversationTimestamps,
//     required this.replyCounts,
//     required this.replyMsgs,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chat List'),
//       ),
//       body: ListView.builder(
//         itemCount: conversationTopics.length,
//         itemBuilder: (context, index) {
//           final topic = conversationTopics[index];
//           final timestamp = conversationTimestamps[index];
//           final count = replyCounts[index];

//           return ListTile(
//             title: Text(topic),
//             subtitle: Text('Timestamp: $timestamp - Replies: $count'),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => ChatsScreen(
//                     topic: topic,
//                     replyMsgs: replyMsgs,
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
