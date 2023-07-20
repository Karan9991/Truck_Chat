import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

// class ChatScreen extends StatefulWidget {
//   final String chatId;

//   ChatScreen({required this.chatId});

//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//  late DatabaseReference _chatRef;
//   TextEditingController _messageController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _chatRef = FirebaseDatabase.instance.reference().child('chats').child(widget.chatId);
//   }

//   void _sendMessage() {
//     String message = _messageController.text.trim();
//     if (message.isNotEmpty) {
//       _chatRef.push().set({
//         'message': message,
//         'timestamp': ServerValue.timestamp,
//       });
//       _messageController.clear();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chat with ${widget.chatId}'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder(
//               stream: _chatRef.orderByChild('timestamp').onValue,
//               builder: (context, snapshot) {
//                 if (snapshot.hasData && snapshot.data != null) {
//                   Map<dynamic, dynamic>? data =
//                       (snapshot.data as DatabaseEvent).snapshot.value as Map<dynamic, dynamic>?;

//                   if (data != null) {
//                     List<String> messageKeys = data.keys.cast<String>().toList();

//                     return ListView.builder(
//                       reverse: true,
//                       itemCount: messageKeys.length,
//                       itemBuilder: (context, index) {
//                         String messageKey = messageKeys[index];
//                         String message = data[messageKey]['message'];
//                         return ListTile(
//                           title: Text(message),
//                         );
//                       },
//                     );
//                   }
//                 }
//                 return Center(
//                   child: CircularProgressIndicator(),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: InputDecoration(
//                       hintText: 'Type a message...',
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.send),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



//testing 1

// class ChatScreen extends StatefulWidget {
//   final String chatId;

//   ChatScreen({required this.chatId});

//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   late DatabaseReference _chatRef;
//   late String currentUserId; // Assuming you have a way to get the current user ID.

//   TextEditingController _messageController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _chatRef = FirebaseDatabase.instance.reference().child('chats').child(widget.chatId);
//     currentUserId = "1"; // Replace with your logic to get the current user ID.
//   }

//   void _sendMessage() {
//     String message = _messageController.text.trim();
//     if (message.isNotEmpty) {
//       _chatRef.push().set({
//         'senderId': currentUserId,
//         'receiverId': '2',
//         'message': message,
//         'timestamp': ServerValue.timestamp,
//       });
//       _messageController.clear();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chat with ${widget.chatId}'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder(
//               stream: _chatRef.orderByChild('timestamp').onValue,
//               builder: (context, snapshot) {
//                 if (snapshot.hasData && snapshot.data != null) {
//                   Map<dynamic, dynamic>? data =
//                       (snapshot.data as DatabaseEvent).snapshot.value as Map<dynamic, dynamic>?;

//                   if (data != null) {
//                     List<String> messageKeys = data.keys.cast<String>().toList();

//                     return ListView.builder(
//                     //  reverse: true,
//                       itemCount: messageKeys.length,
//                       itemBuilder: (context, index) {
//                         String messageKey = messageKeys[index];
//                         Map<dynamic, dynamic> messageData = data[messageKey];
//                         String senderId = messageData['senderId'];
//                         String message = messageData['message'];
//                         bool isCurrentUser = senderId == currentUserId;
//                         return MessageBubble(
//                           message: message,
//                           isCurrentUser: isCurrentUser,
//                         );
//                       },
//                         reverse: true, // Keep latest messages at the bottom

//                     );
//                   }
//                 }
//                 return Center(
//                   child: CircularProgressIndicator(),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: InputDecoration(
//                       hintText: 'Type a message...',
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.send),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class MessageBubble extends StatelessWidget {
//   final String message;
//   final bool isCurrentUser;

//   MessageBubble({required this.message, required this.isCurrentUser});

//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//         margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//         decoration: BoxDecoration(
//           color: isCurrentUser ? Colors.blue : Colors.grey,
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Text(
//           message,
//           style: TextStyle(color: Colors.white),
//         ),
//       ),
//     );
//   }
// }


//testing 2

class ChatScreen extends StatefulWidget {
  final String chatId;

  ChatScreen({required this.chatId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late DatabaseReference _chatRef;
  late String currentUserId; // Assuming you have a way to get the current user ID.

  TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _chatRef = FirebaseDatabase.instance.reference().child('chats').child(widget.chatId);
    currentUserId = "2"; // Replace with your logic to get the current user ID.
  }

  void _sendMessage() {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      _chatRef.push().set({
        'senderId': currentUserId,
        'receiverId': '1',
        'message': message,
        'timestamp': ServerValue.timestamp,
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.chatId}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _chatRef.orderByChild('timestamp').onValue,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  Map<dynamic, dynamic>? data =
                      (snapshot.data as DatabaseEvent).snapshot.value as Map<dynamic, dynamic>?;

                  if (data != null) {
                    List<String> messageKeys = data.keys.cast<String>().toList();



// Sort the messageKeys based on timestamp
messageKeys.sort((a, b) {
  int timestampA = data[a]['timestamp'];
  int timestampB = data[b]['timestamp'];
  return timestampA.compareTo(timestampB);
});
// Reverse the sorted messageKeys list to display latest messages at the bottom
messageKeys = messageKeys.reversed.toList();

// Now the messageKeys list contains keys in the correct chronological order


                    return ListView.builder(
                    //  reverse: true,
                      itemCount: messageKeys.length,
                      itemBuilder: (context, index) {
                        String messageKey = messageKeys[index];
                        Map<dynamic, dynamic> messageData = data[messageKey];
                        String senderId = messageData['senderId'];
                        String message = messageData['message'];
                        bool isCurrentUser = senderId == currentUserId;
                        return MessageBubble(
                          message: message,
                          isCurrentUser: isCurrentUser,
                        );
                      },
                        reverse: true, // Keep latest messages at the bottom

                    );
                  }
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;

  MessageBubble({required this.message, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.blue : Colors.grey,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}