import 'package:chat/chatdemo/chat.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
// class ChatListScreen extends StatefulWidget {
//   @override
//   _ChatListScreenState createState() => _ChatListScreenState();
// }

// class _ChatListScreenState extends State<ChatListScreen> {
//   late DatabaseReference _chatListRef;

//   @override
//   void initState() {
//     super.initState();
//     _chatListRef = FirebaseDatabase.instance.reference().child('chats');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chat List'),
//       ),
//       body: StreamBuilder(
//         stream: _chatListRef.onValue,
//         builder: (context, snapshot) {
//           if (snapshot.hasData && snapshot.data != null) {
//             Map<dynamic, dynamic>? chatList =
//                 (snapshot.data as DatabaseEvent).snapshot.value as Map<dynamic, dynamic>?;
//   print('Chat List: $chatList'); // Add this print statement to check the chatList data.

//             if (chatList != null) {
//               List<String> chatIds = chatList.keys.cast<String>().toList();

//               return ListView.builder(
//                 itemCount: chatIds.length,
//                 itemBuilder: (context, index) {
//                   String chatId = chatIds[index];
//                   String lastMessage = chatList[chatId]['message'] ?? '';
//                   return ListTile(
//                     title: Text('Chat with $chatId'),
//                     subtitle: Text(lastMessage),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => ChatScreen(chatId: chatId),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               );
//             }
//           }
//           return Center(
//             child: CircularProgressIndicator(),
//           );
//         },
//       ),
//     );
//   }
// }

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late DatabaseReference _chatListRef;
  late String
      currentUserId; // Assuming you have a way to get the current user ID.

  @override
  void initState() {
    super.initState();
    _chatListRef = FirebaseDatabase.instance.reference().child('chats');
    currentUserId = "2"; // Replace with your logic to get the current user ID.
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Chat List'),
    ),
    body: StreamBuilder(
      stream: _chatListRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          dynamic data = snapshot.data!.snapshot.value;

          if (data is Map<dynamic, dynamic>) {
            List<String> chatIds = data.keys.cast<String>().toList();
            List<String> participatedChatIds = [];

            // Check if the current user's ID exists in any chat's senderId or receiverId
            for (String chatId in chatIds) {
              Map<dynamic, dynamic> chat = data[chatId] as Map<dynamic, dynamic>;

              // Access senderId and receiverId inside the nested chat data
              String messageId = chat.keys.first as String;
              Map<dynamic, dynamic> messageData = chat[messageId] as Map<dynamic, dynamic>;

              String senderId = messageData['senderId'] ?? '';
              String receiverId = messageData['receiverId'] ?? '';

              print('sender id: $senderId');
              print('receiver id: $receiverId');

              if (currentUserId == senderId || currentUserId == receiverId) {
                participatedChatIds.add(chatId);
              }
            }

            print('ChatList: $data'); // Debug print
            print('ChatIds: $chatIds'); // Debug print
            print('Participated ChatIds: $participatedChatIds'); // Debug print

            return ListView.builder(
              itemCount: participatedChatIds.length,
              itemBuilder: (context, index) {
                String chatId = participatedChatIds[index];
                Map<dynamic, dynamic> chat = data[chatId] as Map<dynamic, dynamic>;

                // Access message data similarly as before
                String messageId = chat.keys.first as String;
                Map<dynamic, dynamic> messageData = chat[messageId] as Map<dynamic, dynamic>;

                String lastMessage = messageData['message'] ?? '';

                return ListTile(
                  title: Text('Chat with $chatId'),
                  subtitle: Text(lastMessage),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(chatId: chatId),
                      ),
                    );
                  },
                );
              },
            );
          }
        }

        return Center(
          child: CircularProgressIndicator(),
        );
      },
    ),
  );
}




}
