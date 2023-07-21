import 'package:chat/chatdemo/chat.dart';
import 'package:chat/utils/avatar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

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
    _chatListRef = FirebaseDatabase.instance.ref().child('chats');
    currentUserId = "2"; // Replace with your logic to get the current user ID.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: _chatListRef.onValue,
        builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
            dynamic data = snapshot.data!.snapshot.value;

            if (data is Map<dynamic, dynamic>) {
              List<String> chatIds = data.keys.cast<String>().toList();
              List<String> participatedChatIds = [];

              // Check if the current user's ID exists in any chat's senderId or receiverId
              for (String chatId in chatIds) {
                Map<dynamic, dynamic> chat =
                    data[chatId] as Map<dynamic, dynamic>;

                // Access senderId and receiverId inside the nested chat data
                String messageId = chat.keys.first as String;
                Map<dynamic, dynamic> messageData =
                    chat[messageId] as Map<dynamic, dynamic>;

                String senderId = messageData['senderId'] ?? '';
                String receiverId = messageData['receiverId'] ?? '';
                print('sender id: $senderId');
                print('receiver id: $receiverId');

                if (currentUserId == senderId || currentUserId == receiverId) {
                  participatedChatIds.add(chatId);
                }
              }

               if (participatedChatIds.isEmpty) {
              return Center(
                child: Text("No Priv Chat list"),
              );
            }

              print('ChatList: $data'); // Debug print
              print('ChatIds: $chatIds'); // Debug print
              print(
                  'Participated ChatIds: $participatedChatIds'); // Debug print

              return ListView.builder(
                itemCount: participatedChatIds.length,
                itemBuilder: (context, index) {
                  String chatId = participatedChatIds[index];
                  Map<dynamic, dynamic> chat =
                      data[chatId] as Map<dynamic, dynamic>;

    
                  // Sort the messageKeys based on timestamp
                  List<String> messageKeys = chat.keys.cast<String>().toList();
                  messageKeys.sort((a, b) {
                    int timestampA = chat[a]['timestamp'] ?? 0;
                    int timestampB = chat[b]['timestamp'] ?? 0;
                    return timestampB
                        .compareTo(timestampA); // Sort in descending order
                  });

                  String lastMessageId =
                      messageKeys.first; // Get the last message ID

                  Map<dynamic, dynamic> messageData =
                      chat[lastMessageId] as Map<dynamic, dynamic>;

                 //testing 1 start

                  String emojiId = '';
                  String userName = '';
                 if(currentUserId == messageData['senderId']){
                    emojiId = messageData['senderEmojiId'];
                   userName = messageData['senderUserName'];

                 }else if(currentUserId == messageData['receiverId']){
                    emojiId = messageData['receiverEmojiId'];
                   userName = messageData['receiverUserName'];
                 }





               //testing 1 end    

                  String lastMessage = messageData['message'] ?? '';
                  // String emojiId = messageData['emojiId'];
                  // String userName = messageData['userName'];
                  int timestamp = messageData['timestamp'] ?? 0;

                  // Format the timestamp into a human-readable date and time format
                  String formattedDateTime = _formatTimestamp(timestamp);

                  Avatar? matchingAvatar = avatars.firstWhere(
                    (avatar) => avatar.id == int.parse(emojiId),
                    orElse: () => Avatar(id: 0, imagePath: ''),
                  );
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(matchingAvatar.imagePath),
                      ),
                      title: Text(userName),
                      subtitle: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              lastMessage,
                              overflow: TextOverflow.ellipsis,
                              maxLines:
                                  1, // Display only one line of the last message
                            ),
                          ),
                          SizedBox(
                              width:
                                  8), // Add some space between the message and the date
                          Text(
                            formattedDateTime,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      //subtitle: Text(lastMessage),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              chatId: chatId,
                              imagePath: matchingAvatar.imagePath,
                              userName: userName,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }
          }

          return Center(
                child: Text("No Private chat list"),
          );
        },
      ),
    );
  }

  // Function to format timestamp into a human-readable date and time format
  String _formatTimestamp(int timestamp) {
    if (timestamp == 0) {
      return ''; // Handle invalid or missing timestamps
    }

    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    String formattedDate = DateFormat('MMM dd, yyyy').format(dateTime);
    String formattedTime = DateFormat('hh:mm a').format(dateTime);

    return '$formattedDate at $formattedTime';
  }
}
