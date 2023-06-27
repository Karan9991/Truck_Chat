import 'package:flutter/material.dart';
import 'get_all_reply_messages.dart';

// class ChatsScreen extends StatelessWidget {
//   final String topic;
//   final List<ReplyMsg> replyMsgs;

//   ChatsScreen({
//     required this.topic,
//     required this.replyMsgs,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(topic),
//       ),
//       body: ListView.builder(
//         itemCount: replyMsgs.length,
//         itemBuilder: (context, index) {
//           final reply = replyMsgs[index];
//           final replyMsg = reply.replyMsg;
//           final timestamp = reply.timestamp;

//           return ListTile(
//             title: Text(replyMsg),
//             subtitle: Text('Timestamp: $timestamp'),
//           );
//         },
//       ),
      
//     );
//   }
// }

class ChatsScreen extends StatelessWidget {
  final String topic;
  final List<ReplyMsg> replyMsgs;

  ChatsScreen({
    required this.topic,
    required this.replyMsgs,
  });

  @override
  Widget build(BuildContext context) {
    List<ReplyMsg> filteredReplyMsgs = replyMsgs.where((reply) => reply.topic == topic).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(topic),
      ),
      body: ListView.builder(
        itemCount: filteredReplyMsgs.length,
        itemBuilder: (context, index) {
          final reply = filteredReplyMsgs[index];
          final replyMsg = reply.replyMsg;
          final timestamp = reply.timestamp;

          return ListTile(
            title: Text(replyMsg),
            subtitle: Text('Timestamp: $timestamp'),
          );
        },
      ),
    );
  }
}
