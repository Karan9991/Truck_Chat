// import 'dart:html';

import 'package:flutter/material.dart';
import 'get_all_reply_messages.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_6.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'get_all_reply_messages.dart';
// class ChatsScreen extends StatelessWidget {
//   final String topic;
//   final List<ReplyMsg> replyMsgs;

//   ChatsScreen({
//     required this.topic,
//     required this.replyMsgs,
//   });

//    @override
//   Widget build(BuildContext context) {
//     List<ReplyMsg> filteredReplyMsgs =
//         replyMsgs.where((reply) => reply.topic == topic).toList();

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(topic),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//        Padding(
//   padding: EdgeInsets.all(8.0),
//   child: Container(
//     padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//     decoration: BoxDecoration(
//       color: Colors.blue[300],
//       borderRadius: BorderRadius.circular(8.0),
//     ),
//     child: Text(
//       topic,
//       style: TextStyle(
//         fontSize: 24,
//         fontWeight: FontWeight.bold,
//         color: Colors.white,
//       ),
//     ),
//   ),
// ),

//           Expanded(
//             child: ListView.builder(
//               itemCount: filteredReplyMsgs.length,
//               itemBuilder: (context, index) {
//                 final reply = filteredReplyMsgs[index];
//                 final replyMsg = reply.replyMsg;
//                 final timestampp = reply.timestamp;

//                 DateTime dateTime =
//                     DateTime.fromMillisecondsSinceEpoch(timestampp);
//                 String formattedDateTime =
//                     DateFormat('MMM d, yyyy h:mm:ss a').format(dateTime);
//                 final timestamp = formattedDateTime;

//                 return Padding(
//                   padding: EdgeInsets.all(8.0),
//                   child: ChatBubble(
//                     clipper: ChatBubbleClipper6(type: BubbleType.receiverBubble),
//                     alignment: Alignment.topLeft,
//                     margin: EdgeInsets.only(bottom: 16.0),
//                     backGroundColor: Colors.blue[300],
//                     child: Container(
//                       constraints: BoxConstraints(maxWidth: 250.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             replyMsg,
//                             style: TextStyle(color: Colors.black, fontSize: 20),
//                           ),
//                           SizedBox(height: 4.0),
//                           Text(
//                             timestamp,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

// }

//void sendMessage() {
// if (messageController.text.isNotEmpty) {
//   setState(() {
//     final newReplyMsg = ReplyMsg(
//       "1", // Generate a unique ID for the message
//       "userId", // Replace with the actual user ID
//       messageController.text,
//       DateTime.now().millisecondsSinceEpoch,
//       0,
//     );
//     widget.replyMsgs.add(newReplyMsg);
//     filterReplyMsgs();
//     messageController.clear();
//   });
// }
//}

//original 2

// class ChatsScreen extends StatefulWidget {
//   final String topic;
//   final List<ReplyMsg> replyMsgs;
//   final String serverMsgId;

//   ChatsScreen({
//     required this.topic,
//     required this.replyMsgs,
//     required this.serverMsgId,
//   });

//   @override
//   _ChatsScreenState createState() => _ChatsScreenState();
// }

// class _ChatsScreenState extends State<ChatsScreen> {
//   TextEditingController messageController = TextEditingController();
//   List<ReplyMsg> filteredReplyMsgs = [];
//   int rid = 0;
//   String emoji_id = '';
//   int timestam = 0;
//   String status_message = '';
//   int statusCode = 0;

//   @override
//   void initState() {
//     super.initState();
//     filterReplyMsgs();
//   }

//   void filterReplyMsgs() {
//     filteredReplyMsgs =
//         widget.replyMsgs.where((reply) => reply.topic == widget.topic).toList();
//   }

//   Future<bool> sendMessage(
//     String message,
//     String serverMsgId,
//     int userId,
//     String emojiId,
//   ) async {
//     print('send message');
//     print('message $message');
//     print('sermsgid $serverMsgId');
//     print('userid $userId');
//     print('emojiid $emoji_id');

//     int servermsgid = int.parse(serverMsgId);
//     final url =
//         'http://smarttruckroute.com/bb/v1/device_post_message'; // Replace with your API endpoint
//     final headers = {'Content-Type': 'application/json'};
//     final body = jsonEncode({
//       'message': message,
//       'server_msg_id': servermsgid,
//       'user_id': userId,
//       'latitude': 1.0,
//       'longitude': 1.0,
//       'emoji_id': emojiId,
//     });

//     try {
//       final response =
//           await http.post(Uri.parse(url), headers: headers, body: body);

//       print(response.body);

//       if (response.statusCode == 200) {
//         final jsonResult = jsonDecode(response.body);
//         int statusCode = jsonResult['status'] as int;
//         print('status code $statusCode');

//         if (jsonResult.containsKey('message')) {
//           String status_message = jsonResult['message'] as String;
//           print('status_message $status_message');
//         } else {
//           String status_message = '';
//         }

//         return true;
//       } else {
//         status_message = 'Error: ${response.statusCode}';
//       }
//     } catch (e) {
//       status_message = e.toString();
//     }

//     return false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.topic),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: EdgeInsets.only(top: 8, left: 0, right: 8),
//             child: Container(
//               padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//               decoration: BoxDecoration(
//                 color: Colors.blue[300],
//                 borderRadius: BorderRadius.circular(8.0),
//               ),
//               child: Text(
//                 widget.topic,
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: filteredReplyMsgs.length,
//               itemBuilder: (context, index) {
//                 final reply = filteredReplyMsgs[index];
//                 final replyMsg = reply.replyMsg;
//                 final timestampp = reply.timestamp;

//                 DateTime dateTime =
//                     DateTime.fromMillisecondsSinceEpoch(timestampp);
//                 String formattedDateTime =
//                     DateFormat('MMM d, yyyy h:mm:ss a').format(dateTime);
//                 final timestamp = formattedDateTime;

//                 rid = reply.rid;
//                 emoji_id = reply.emojiId;
//                 timestam = timestampp;

//                 return Padding(
//                   padding: EdgeInsets.all(8.0),
//                   child: ChatBubble(
//                     clipper:
//                         ChatBubbleClipper6(type: BubbleType.receiverBubble),
//                     alignment: Alignment.topLeft,
//                     margin: EdgeInsets.only(bottom: 16.0),
//                     backGroundColor: Colors.blue[300],
//                     child: Container(
//                       constraints: BoxConstraints(maxWidth: 250.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             replyMsg,
//                             style: TextStyle(color: Colors.black, fontSize: 20),
//                           ),
//                           SizedBox(height: 4.0),
//                           Text(
//                             timestamp,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//             decoration: BoxDecoration(
//               color: Colors.grey[200],
//               borderRadius: BorderRadius.circular(24.0),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: messageController,
//                     decoration: InputDecoration(
//                       hintText: 'Type your message...',
//                       border: InputBorder.none,
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 8.0),
//                 FloatingActionButton(
//                   onPressed: () async {
//                     bool messageSent = await sendMessage(messageController.text,
//                         widget.serverMsgId, 69979, emoji_id);
//                     if (messageSent) {
//                       print('message send');
//                       // Message sent successfully, handle any UI updates if needed
//                     } else {
//                       print('message failed not sent');

//                       // Failed to send the message, handle any UI updates if needed
//                     }
//                   },

//                   // onPressed: () async => {
//                   //    bool messageSent = await sendMessage(messageController.text, rid, 69979, emoji_id)
//                   // },
//                   backgroundColor: Colors.blue,
//                   child: Icon(Icons.send),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

// }

///testing 2 message appear

// class ChatsScreen extends StatefulWidget {
//   final String topic;
//   final List<ReplyMsg> replyMsgs;
//   final String serverMsgId;

//   ChatsScreen({
//     required this.topic,
//     required this.replyMsgs,
//     required this.serverMsgId,
//   });

//   @override
//   _ChatsScreenState createState() => _ChatsScreenState();
// }

// class _ChatsScreenState extends State<ChatsScreen> {
//   TextEditingController messageController = TextEditingController();
//   List<ReplyMsg> filteredReplyMsgs = [];
//   List<ReplyMsgg> sentMessages = [];
//   int rid = 0;
//   String emoji_id = '';
//   int timestam = 0;
//   String status_message = '';
//   int statusCode = 0;

//   @override
//   void initState() {
//     super.initState();
//     filterReplyMsgs();
//   }

//   void filterReplyMsgs() {
//     filteredReplyMsgs =
//         widget.replyMsgs.where((reply) => reply.topic == widget.topic).toList();
//   }

//   Future<bool> sendMessage(
//     String message,
//     String serverMsgId,
//     int userId,
//     String emojiId,
//   ) async {
//     print('send message');
//     print('message $message');
//     print('sermsgid $serverMsgId');
//     print('userid $userId');
//     print('emojiid $emoji_id');

//     int servermsgid = int.parse(serverMsgId);
//     final url =
//         'http://smarttruckroute.com/bb/v1/device_post_message'; // Replace with your API endpoint
//     final headers = {'Content-Type': 'application/json'};
//     final body = jsonEncode({
//       'message': message,
//       'server_msg_id': servermsgid,
//       'user_id': userId,
//       'latitude': 1.0,
//       'longitude': 1.0,
//       'emoji_id': emojiId,
//     });

//     try {
//       final response =
//           await http.post(Uri.parse(url), headers: headers, body: body);

//       print(response.body);

//       if (response.statusCode == 200) {
//         final jsonResult = jsonDecode(response.body);
//         int statusCode = jsonResult['status'] as int;
//         print('status code $statusCode');

//         if (jsonResult.containsKey('message')) {
//           String status_message = jsonResult['message'] as String;
//           print('status_message $status_message');

//           // Add the sent message to the list
//           sentMessages.add(ReplyMsgg(servermsgid, userId, message, DateTime.now().millisecondsSinceEpoch));
//         } else {
//           String status_message = '';
//         }

//         return true;
//       } else {
//         status_message = 'Error: ${response.statusCode}';
//       }
//     } catch (e) {
//       status_message = e.toString();
//     }

//     return false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.topic),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: EdgeInsets.only(top: 8, left: 0, right: 8),
//             child: Container(
//               padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//               decoration: BoxDecoration(
//                 color: Colors.blue[300],
//                 borderRadius: BorderRadius.circular(8.0),
//               ),
//               child: Text(
//                 widget.topic,
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: filteredReplyMsgs.length + sentMessages.length,
//               itemBuilder: (context, index) {
//                 if (index < filteredReplyMsgs.length) {
//                   final reply = filteredReplyMsgs[index];
//                   final replyMsg = reply.replyMsg;
//                   final timestampp = reply.timestamp;

//                   DateTime dateTime =
//                       DateTime.fromMillisecondsSinceEpoch(timestampp);
//                   String formattedDateTime =
//                       DateFormat('MMM d, yyyy h:mm:ss a').format(dateTime);
//                   final timestamp = formattedDateTime;

//                   rid = reply.rid;
//                   emoji_id = reply.emojiId;
//                   timestam = timestampp;

//                   return Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: ChatBubble(
//                       clipper: ChatBubbleClipper6(type: BubbleType.receiverBubble),
//                       alignment: Alignment.topLeft,
//                       margin: EdgeInsets.only(bottom: 16.0),
//                       backGroundColor: Colors.blue[300],
//                       child: Container(
//                         constraints: BoxConstraints(maxWidth: 250.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               replyMsg,
//                               style: TextStyle(color: Colors.black, fontSize: 20),
//                             ),
//                             SizedBox(height: 4.0),
//                             Text(
//                               timestamp,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 } else {
//                   final sentIndex = index - filteredReplyMsgs.length;
//                   final sentMessage = sentMessages[sentIndex];
//                   final timestampp = sentMessage.timestamp;

//                   DateTime dateTime =
//                       DateTime.fromMillisecondsSinceEpoch(timestampp);
//                   String formattedDateTime =
//                       DateFormat('MMM d, yyyy h:mm:ss a').format(dateTime);
//                   final timestamp = formattedDateTime;

//                   return Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: ChatBubble(
//                       clipper: ChatBubbleClipper6(type: BubbleType.receiverBubble),
//                       alignment: Alignment.topLeft,
//                       margin: EdgeInsets.only(bottom: 16.0),
//                       backGroundColor: Colors.blue[300],
//                       child: Container(
//                         constraints: BoxConstraints(maxWidth: 250.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               sentMessage.replyMsg,
//                               style: TextStyle(color: Colors.black, fontSize: 20),
//                             ),
//                             SizedBox(height: 4.0),
//                             Text(
//                               timestamp,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 }
//               },
//             ),
//           ),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//             decoration: BoxDecoration(
//               color: Colors.grey[200],
//               borderRadius: BorderRadius.circular(24.0),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: messageController,
//                     decoration: InputDecoration(
//                       hintText: 'Type your message...',
//                       border: InputBorder.none,
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 8.0),
//                 FloatingActionButton(
//                   onPressed: () async {
//                     bool messageSent = await sendMessage(
//                       messageController.text,
//                       widget.serverMsgId,
//                       69979,
//                       emoji_id,
//                     );
//                     if (messageSent) {
//                       print('message send');
//                       // Message sent successfully, handle any UI updates if needed
//                     } else {
//                       print('message failed not sent');
//                       // Failed to send the message, handle any UI updates if needed
//                     }
//                     setState(() {
//                       messageController.clear();
//                     });
//                   },
//                   backgroundColor: Colors.blue,
//                   child: Icon(Icons.send),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class ReplySMsg {
  final String replyMsg;
  final int timestamp;
  final int rid;
  final String emojiId;

  ReplySMsg({
    required this.replyMsg,
    required this.timestamp,
    required this.rid,
    required this.emojiId,
  });
}

//testing 3

// class ChatsScreen extends StatefulWidget {
//   final String topic;
//   final List<ReplyMsg> replyMsgs;
//   final String serverMsgId;

//   ChatsScreen({
//     required this.topic,
//     required this.replyMsgs,
//     required this.serverMsgId,
//   });

//   @override
//   _ChatsScreenState createState() => _ChatsScreenState();
// }

// class _ChatsScreenState extends State<ChatsScreen> {
//   TextEditingController messageController = TextEditingController();
//   List<ReplyMsg> filteredReplyMsgs = [];
//   List<ReplyMsgg> sentMessages = [];
//   int rid = 0;
//   String emoji_id = '';
//   int timestam = 0;
//   String status_message = '';
//   int statusCode = 0;

//   @override
//   void initState() {
//     super.initState();
//     filterReplyMsgs();
//   }

//   void filterReplyMsgs() {
//     filteredReplyMsgs =
//         widget.replyMsgs.where((reply) => reply.topic == widget.topic).toList();
//   }

//   Future<bool> sendMessage(
//     String message,
//     String serverMsgId,
//     int userId,
//     String emojiId,
//   ) async {
//     print('send message');
//     print('message $message');
//     print('sermsgid $serverMsgId');
//     print('userid $userId');
//     print('emojiid $emoji_id');

//     int servermsgid = int.parse(serverMsgId);
//     final url =
//         'http://smarttruckroute.com/bb/v1/device_post_message'; // Replace with your API endpoint
//     final headers = {'Content-Type': 'application/json'};
//     final body = jsonEncode({
//       'message': message,
//       'server_msg_id': servermsgid,
//       'user_id': userId,
//       'latitude': 1.0,
//       'longitude': 1.0,
//       'emoji_id': emojiId,
//     });

//     try {
//       final response =
//           await http.post(Uri.parse(url), headers: headers, body: body);

//       print(response.body);

//       if (response.statusCode == 200) {
//         final jsonResult = jsonDecode(response.body);
//         int statusCode = jsonResult['status'] as int;
//         print('status code $statusCode');

//         if (jsonResult.containsKey('message')) {
//           String status_message = jsonResult['message'] as String;
//           print('status_message $status_message');

//           // Add the sent message to the list
//           sentMessages.add(ReplyMsgg(servermsgid, userId, message, DateTime.now().millisecondsSinceEpoch));
//         } else {
//           String status_message = '';
//         }

//         return true;
//       } else {
//         status_message = 'Error: ${response.statusCode}';
//       }
//     } catch (e) {
//       status_message = e.toString();
//     }

//     return false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.topic),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: EdgeInsets.only(top: 8, left: 0, right: 8),
//             child: Container(
//               padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//               decoration: BoxDecoration(
//                 color: Colors.blue[300],
//                 borderRadius: BorderRadius.circular(8.0),
//               ),
//               child: Text(
//                 widget.topic,
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               reverse: true, // Reverse the list to show sent messages at the bottom
//               itemCount: filteredReplyMsgs.length + sentMessages.length,
//               itemBuilder: (context, index) {
//                 if (index >= filteredReplyMsgs.length) {
//                   final sentIndex = index - filteredReplyMsgs.length;
//                   final sentMessage = sentMessages[sentIndex];
//                   final timestampp = sentMessage.timestamp;

//                   DateTime dateTime =
//                       DateTime.fromMillisecondsSinceEpoch(timestampp);
//                   String formattedDateTime =
//                       DateFormat('MMM d, yyyy h:mm:ss a').format(dateTime);
//                   final timestamp = formattedDateTime;

//                   return Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: ChatBubble(
//                       clipper: ChatBubbleClipper6(type: BubbleType.sendBubble), // Use sendBubble for sent messages
//                       alignment: Alignment.topRight,
//                       margin: EdgeInsets.only(bottom: 16.0),
//                       backGroundColor: Colors.blue[300],
//                       child: Container(
//                         constraints: BoxConstraints(maxWidth: 250.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.end,
//                           children: [
//                             Text(
//                               sentMessage.replyMsg,
//                               style: TextStyle(color: Colors.black, fontSize: 20),
//                             ),
//                             SizedBox(height: 4.0),
//                             Text(
//                               timestamp,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 } else {
//                   final reply = filteredReplyMsgs[index];
//                   final replyMsg = reply.replyMsg;
//                   final timestampp = reply.timestamp;

//                   DateTime dateTime =
//                       DateTime.fromMillisecondsSinceEpoch(timestampp);
//                   String formattedDateTime =
//                       DateFormat('MMM d, yyyy h:mm:ss a').format(dateTime);
//                   final timestamp = formattedDateTime;

//                   rid = reply.rid;
//                   emoji_id = reply.emojiId;
//                   timestam = timestampp;

//                   return Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: ChatBubble(
//                       clipper: ChatBubbleClipper6(type: BubbleType.receiverBubble),
//                       alignment: Alignment.topLeft,
//                       margin: EdgeInsets.only(bottom: 16.0),
//                       backGroundColor: Colors.blue[300],
//                       child: Container(
//                         constraints: BoxConstraints(maxWidth: 250.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               replyMsg,
//                               style: TextStyle(color: Colors.black, fontSize: 20),
//                             ),
//                             SizedBox(height: 4.0),
//                             Text(
//                               timestamp,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 }
//               },
//             ),
//           ),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//             decoration: BoxDecoration(
//               color: Colors.grey[200],
//               borderRadius: BorderRadius.circular(24.0),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: messageController,
//                     decoration: InputDecoration(
//                       hintText: 'Type your message...',
//                       border: InputBorder.none,
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 8.0),
//                 FloatingActionButton(
//                   onPressed: () async {
//                     bool messageSent = await sendMessage(
//                       messageController.text,
//                       widget.serverMsgId,
//                       69979,
//                       emoji_id,
//                     );
//                     if (messageSent) {
//                       print('message send');
//                       // Message sent successfully, handle any UI updates if needed
//                     } else {
//                       print('message failed not sent');
//                       // Failed to send the message, handle any UI updates if needed
//                     }
//                     setState(() {
//                       messageController.clear();
//                     });
//                   },
//                   backgroundColor: Colors.blue,
//                   child: Icon(Icons.send),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

//testing 44

class ChatsScreen extends StatefulWidget {
  final String topic;
  final List<ReplyMsg> replyMsgs;
  final String serverMsgId;

  ChatsScreen({
    required this.topic,
    required this.replyMsgs,
    required this.serverMsgId,
  });

  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  TextEditingController messageController = TextEditingController();
  List<ReplyMsg> filteredReplyMsgs = [];
  List<ReplyMsgg> sentMessages = [];
  int rid = 0;
  String emoji_id = '';
  int timestam = 0;
  String status_message = '';
  int statusCode = 0;

  @override
  void initState() {
    super.initState();
    filterReplyMsgs();
  }

  void filterReplyMsgs() {
    filteredReplyMsgs =
        widget.replyMsgs.where((reply) => reply.topic == widget.topic).toList();
  }

  Future<bool> sendMessage(
    String message,
    String serverMsgId,
    int userId,
    String emojiId,
  ) async {
    print('send message');
    print('message $message');
    print('sermsgid $serverMsgId');
    print('userid $userId');
    print('emojiid $emoji_id');

    int servermsgid = int.parse(serverMsgId);
    final url =
        'http://smarttruckroute.com/bb/v1/device_post_message'; // Replace with your API endpoint
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'message': message,
      'server_msg_id': servermsgid,
      'user_id': userId,
      'latitude': 1.0,
      'longitude': 1.0,
      'emoji_id': emojiId,
    });

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      print(response.body);

      if (response.statusCode == 200) {
        final jsonResult = jsonDecode(response.body);
        int statusCode = jsonResult['status'] as int;
        print('status code $statusCode');

        if (jsonResult.containsKey('message')) {
          String status_message = jsonResult['message'] as String;
          print('status_message $status_message');

          // Add the sent message to the list
          sentMessages.add(ReplyMsgg(servermsgid, userId, message,
              DateTime.now().millisecondsSinceEpoch));
        } else {
          String status_message = '';
        }

        return true;
      } else {
        status_message = 'Error: ${response.statusCode}';
      }
    } catch (e) {
      status_message = e.toString();
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 8, left: 0, right: 8),
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
                      69979; // Check if the user_id is equal to 69979

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
                      69979; // Check if the user_id is equal to 69979

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
                      hintText: 'Type your message...',
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
                      69979,
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
                  child: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
