import 'package:flutter/material.dart';
import 'get_all_reply_messages.dart';

class ChatsScreen extends StatelessWidget {
  final String topic;
  final List<ReplyMsg> replyMsgs;

  ChatsScreen({
    required this.topic,
    required this.replyMsgs,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(topic),
      ),
      body: ListView.builder(
        itemCount: replyMsgs.length,
        itemBuilder: (context, index) {
          final reply = replyMsgs[index];
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
// class ReplyMsg {
//   final String rid;
//   final String uid;
//   final String replyMsg;
//   final int timestamp;
//   final String emojiId;

//   ReplyMsg(this.rid, this.uid, this.replyMsg, this.timestamp, this.emojiId);
// }