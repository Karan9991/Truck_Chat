// import 'package:flutter/material.dart';

// class ConversationListPage extends StatefulWidget {
//   final List<Conversation> conversations;

//   ConversationListPage({required this.conversations});

//   @override
//   _ConversationListPageState createState() => _ConversationListPageState();
// }

// class _ConversationListPageState extends State<ConversationListPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Conversations'),
//       ),
//       body: ListView.builder(
//         itemCount: widget.conversations.length,
//         itemBuilder: (context, index) {
//           final conversation = widget.conversations[index];
//           return ListTile(
//             title: Text(conversation.topic),
//             subtitle: Text('Reply Count: ${conversation.replyCount}'),
//             trailing: Text('Timestamp: ${conversation.timestamp}'),
//             onTap: () {
//               // Navigate to chat screen and pass conversation data
//               // Navigator.push(
//               //   context,
//               //   MaterialPageRoute(
//               //     builder: (context) => ChatScreen(conversation: conversation),
//               //   ),
//               // );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// class ChatScreen extends StatelessWidget {
//   final Conversation conversation;

//   ChatScreen({required this.conversation});

//   @override
//   Widget build(BuildContext context) {
//     // Implement the chat screen UI using the conversation data
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chat'),
//       ),
//       body: Center(
//         child: Text('Chat Screen - Topic: ${conversation.topic}'),
//       ),
//     );
//   }
// }

// class Conversation {
//   final String topic;
//   final int replyCount;
//   final int timestamp;

//   Conversation({
//     required this.topic,
//     required this.replyCount,
//     required this.timestamp,
//   });
// }

// // Usage:
// // Inside your runNow() function, after retrieving the data
// List<Conversation> conversations = [];

// if (counts == jsonReplyList.length) {
//   for (var i = 0; i < counts; ++i) {
//     final jsonReply = jsonReplyList[i];
//     final rid = jsonReply['server_msg_reply_id'];
//     final replyMsg = jsonReply['reply_msg'];
//     final uid = jsonReply['user_id'];
//     final emojiId = jsonReply['emoji_id'];
//     int timestamp;
//     try {
//       timestamp = int.tryParse(jsonReply['timestamp']) ?? 0;
//     } catch (e) {
//       timestamp = 0;
//     }

//     reply_msgs.add(ReplyMsg(rid, uid, replyMsg, timestamp, emojiId));
//   }

//   // Create Conversation object and add it to the list
//   final conversation = Conversation(
//     topic: conversation_topic,
//     replyCount: counts,
//     timestamp: conversation_timestamp,
//   );
//   conversations.add(conversation);
// }

// // After fetching all conversations, navigate to ConversationListPage
// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (context) => ConversationListPage(conversations: conversations),
//   ),
// );
