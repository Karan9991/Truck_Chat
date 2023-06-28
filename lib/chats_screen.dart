import 'package:flutter/material.dart';
import 'get_all_reply_messages.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_6.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
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

//testing

class ChatsScreen extends StatefulWidget {
  final String topic;
  final List<ReplyMsg> replyMsgs;

  ChatsScreen({
    required this.topic,
    required this.replyMsgs,
  });

  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  TextEditingController messageController = TextEditingController();
  List<ReplyMsg> filteredReplyMsgs = [];
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

  Future<bool> sendMessage(
    String message,
    int serverMsgId,
    int userId,
    String emojiId,
  ) async {
    print('send message');
    print('message $message');
    print('sermsgid $serverMsgId');
    print('userid $userId');
    print('emojiid $emoji_id');
    final url =
        'http://smarttruckroute.com/bb/v1/device_post_message'; // Replace with your API endpoint
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'message': message,
      'server_msg_id': serverMsgId,
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
              itemCount: filteredReplyMsgs.length,
              itemBuilder: (context, index) {
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

                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: ChatBubble(
                    clipper:
                        ChatBubbleClipper6(type: BubbleType.receiverBubble),
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.only(bottom: 16.0),
                    backGroundColor: Colors.blue[300],
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 250.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            replyMsg,
                            style: TextStyle(color: Colors.black, fontSize: 20),
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
                        messageController.text, rid, 69979, emoji_id);
                    if (messageSent) {
                      print('message send');
                      // Message sent successfully, handle any UI updates if needed
                    } else {
                      print('message failed not sent');

                      // Failed to send the message, handle any UI updates if needed
                    }
                  },

                  // onPressed: () async => {
                  //    bool messageSent = await sendMessage(messageController.text, rid, 69979, emoji_id)
                  // },
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

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text(widget.topic),
  //     ),
  //     body: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Padding(
  //           padding: EdgeInsets.only(top: 8, left: 0, right: 8),
  //           child: Container(
  //             padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
  //             decoration: BoxDecoration(
  //               color: Colors.blue[300],
  //               borderRadius: BorderRadius.circular(8.0),
  //             ),
  //             child: Text(
  //               widget.topic,
  //               style: TextStyle(
  //                 fontSize: 24,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.white,
  //               ),
  //             ),
  //           ),
  //         ),
  //         Expanded(
  //           child: ListView.builder(
  //             itemCount: filteredReplyMsgs.length,
  //             itemBuilder: (context, index) {
  //               final reply = filteredReplyMsgs[index];
  //               final replyMsg = reply.replyMsg;
  //               final timestampp = reply.timestamp;

  //               DateTime dateTime =
  //                   DateTime.fromMillisecondsSinceEpoch(timestampp);
  //               String formattedDateTime =
  //                   DateFormat('MMM d, yyyy h:mm:ss a').format(dateTime);
  //               final timestamp = formattedDateTime;

  //               return Padding(
  //                 padding: EdgeInsets.all(8.0),
  //                 child: ChatBubble(
  //                   clipper:
  //                       ChatBubbleClipper6(type: BubbleType.receiverBubble),
  //                   alignment: Alignment.topLeft,
  //                   margin: EdgeInsets.only(bottom: 16.0),
  //                   backGroundColor: Colors.blue[300],
  //                   child: Container(
  //                     constraints: BoxConstraints(maxWidth: 250.0),
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Text(
  //                           replyMsg,
  //                           style: TextStyle(color: Colors.black, fontSize: 20),
  //                         ),
  //                         SizedBox(height: 4.0),
  //                         Text(
  //                           timestamp,
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               );
  //             },
  //           ),
  //         ),
  //         Container(
  //           padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  //           decoration: BoxDecoration(
  //             color: Colors.grey[200],
  //             borderRadius: BorderRadius.circular(24.0),
  //           ),
  //           child: Row(
  //             children: [
  //               Expanded(
  //                 child: TextField(
  //                   controller: messageController,
  //                   decoration: InputDecoration(
  //                     hintText: 'Type your message...',
  //                     border: InputBorder.none,
  //                   ),
  //                 ),
  //               ),
  //               SizedBox(width: 8.0),
  //               FloatingActionButton(
  //                 onPressed: () => _sendMessageWithIndex(context),
  //                 backgroundColor: Colors.blue,
  //                 child: Icon(Icons.send),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _sendMessageWithIndex(BuildContext context) {
    // Access the index here
    final index = ModalRoute.of(context)?.settings.arguments as int?;

    print('send message');
    print('index $index');

    if (index != null) {
      final reply = filteredReplyMsgs[index];
      final message = messageController.text;
      final rid = reply.rid;
      final uid = reply.uid;
      final emojiid = reply.emojiId;

      print('rid $rid');

      // sendMessage(message, rid, uid, emojiid);
    }
  }
}
