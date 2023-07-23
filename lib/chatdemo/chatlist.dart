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
  String emojiId = '';
  String userName = '';
  late String
      currentUserId; // Assuming you have a way to get the current user ID.

  late DatabaseReference requestsRef;
  List<Map<dynamic, dynamic>> chatDataList = [];

  @override
  void initState() {
    super.initState();
    _chatListRef = FirebaseDatabase.instance.ref().child('chats');
    currentUserId = "1"; // Replace with your logic to get the current user ID.

    requestsRef = FirebaseDatabase.instance.ref().child('chatlist');

    getData();
  }

  // Method to get the correct emojiId and userName for a chat item
  // Map<String, dynamic> getEmojiIdAndUserName(Map<dynamic, dynamic> messageData) {
  //   String emojiId = '';
  //   String userName = '';

  //   String senderId = messageData['senderId'] ?? '';
  //   String receiverId = messageData['receiverId'] ?? '';

  //   if (currentUserId == senderId) {
  //     emojiId = messageData['senderEmojiId'] ?? '';
  //     userName = messageData['senderUserName'] ?? '';
  //   } else if (currentUserId == receiverId) {
  //     emojiId = messageData['receiverEmojiId'] ?? '';
  //     userName = messageData['receiverUserName'] ?? '';
  //   }

  //   return {'emojiId': emojiId, 'userName': userName};
  // }

//original get data
  // void getData() {
  //   print('getdata');
  //   requestsRef
  //       .orderByChild('receiverId')
  //       .equalTo(currentUserId)
  //       .onValue
  //       .listen((event) {
  //     DataSnapshot snapshot = event.snapshot;

  //     if (snapshot != null && snapshot.value != null) {
  //       Map<dynamic, dynamic> requestsData =
  //           snapshot.value as Map<dynamic, dynamic>;

  //       List<Widget> requestWidgets = [];

  //       requestsData.forEach((requestId, requestData) {
  //         if (currentUserId == requestData['senderId']) {
  //           emojiId = requestData['receiverEmojiId'];
  //           userName = requestData['receiverUserName'];

  //           print('get data iiiiiiiiffffffff');

  //           print('username $userName');
  //         } else {
  //           emojiId = requestData['senderEmojiId'];
  //           userName = requestData['senderUserName'];
  //           print('get data eeeeeeeelse');
  //           print('username $userName');
  //         }
  //       });

  //       // Now you can use the requestWidgets list as needed.
  //     }
  //   }, onError: (error) {
  //     // Handle any errors that may occur during data retrieval.
  //     print('Error: $error');
  //   });

  //   requestsRef.orderByChild('senderId').equalTo(currentUserId).onValue.listen(
  //       (event) {
  //     DataSnapshot snapshot = event.snapshot;

  //     if (snapshot != null && snapshot.value != null) {
  //       Map<dynamic, dynamic> requestsData =
  //           snapshot.value as Map<dynamic, dynamic>;

  //       List<Widget> requestWidgets = [];

  //       requestsData.forEach((requestId, requestData) {
  //         if (currentUserId == requestData['senderId']) {
  //                    emojiId = requestData['receiverEmojiId'];
  //           userName = requestData['receiverUserName'];
  //           print('get data iiiiiiiiffffffff');

  //           print('username $userName');
  //         } else {
  //              emojiId = requestData['senderEmojiId'];
  //           userName = requestData['senderUserName'];
  //           print('get data eeeeeeeelse');
  //           print('username $userName');
  //         }
  //       });

  //       // Now you can use the requestWidgets list as needed.
  //     }
  //   }, onError: (error) {
  //     // Handle any errors that may occur during data retrieval.
  //     print('Error: $error');
  //   });
  // }

  //testing get data
  void getData() {
    print('getdata');
    requestsRef
        .orderByChild('receiverId')
        .equalTo(currentUserId)
        .onValue
        .listen((event) {
      DataSnapshot snapshot = event.snapshot;

      if (snapshot != null && snapshot.value != null) {
        Map<dynamic, dynamic> requestsData =
            snapshot.value as Map<dynamic, dynamic>;

        chatDataList.clear();

        requestsData.forEach((requestId, requestData) {
          Map<dynamic, dynamic> chatData = {};
          if (currentUserId == requestData['senderId']) {
            chatData['emojiId'] = requestData['receiverEmojiId'];
            chatData['userName'] = requestData['receiverUserName'];
          } else {
            chatData['emojiId'] = requestData['senderEmojiId'];
            chatData['userName'] = requestData['senderUserName'];
          }
          chatDataList.add(chatData);
        });

        // Now you can use the requestWidgets list as needed.
      }
    }, onError: (error) {
      // Handle any errors that may occur during data retrieval.
      print('Error: $error');
    });

    requestsRef.orderByChild('senderId').equalTo(currentUserId).onValue.listen(
        (event) {
      DataSnapshot snapshot = event.snapshot;

      if (snapshot != null && snapshot.value != null) {
     Map<dynamic, dynamic> requestsData =
            snapshot.value as Map<dynamic, dynamic>;

        chatDataList.clear();

        requestsData.forEach((requestId, requestData) {
          Map<dynamic, dynamic> chatData = {};
          if (currentUserId == requestData['senderId']) {
            chatData['emojiId'] = requestData['receiverEmojiId'];
            chatData['userName'] = requestData['receiverUserName'];
          } else {
            chatData['emojiId'] = requestData['senderEmojiId'];
            chatData['userName'] = requestData['senderUserName'];
          }
          chatDataList.add(chatData);
        });

        // Now you can use the requestWidgets list as needed.
      }
    }, onError: (error) {
      // Handle any errors that may occur during data retrieval.
      print('Error: $error');
    });
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: StreamBuilder(
  //       stream: _chatListRef.onValue,
  //       builder: (context, snapshot) {
  //         if (snapshot.connectionState == ConnectionState.waiting) {
  //           return Center(
  //             child: CircularProgressIndicator(),
  //           );
  //         } else if (snapshot.hasData && snapshot.data != null) {
  //           dynamic data = snapshot.data!.snapshot.value;

  //           if (data is Map<dynamic, dynamic>) {
  //             List<String> chatIds = data.keys.cast<String>().toList();
  //             List<String> participatedChatIds = [];

  //             // Check if the current user's ID exists in any chat's senderId or receiverId
  //             for (String chatId in chatIds) {
  //               Map<dynamic, dynamic> chat =
  //                   data[chatId] as Map<dynamic, dynamic>;

  //               // Access senderId and receiverId inside the nested chat data
  //               String messageId = chat.keys.first as String;
  //               Map<dynamic, dynamic> messageData =
  //                   chat[messageId] as Map<dynamic, dynamic>;

  //               String senderId = messageData['senderId'] ?? '';
  //               String receiverId = messageData['receiverId'] ?? '';
  //               print('sender id: $senderId');
  //               print('receiver id: $receiverId');

  //               if (currentUserId == senderId || currentUserId == receiverId) {
  //                 participatedChatIds.add(chatId);
  //               }
  //             }

  //             if (participatedChatIds.isEmpty) {
  //               return Center(
  //                 child: Text("No Priv Chat list"),
  //               );
  //             }

  //             print('ChatList: $data'); // Debug print
  //             print('ChatIds: $chatIds'); // Debug print
  //             print(
  //                 'Participated ChatIds: $participatedChatIds'); // Debug print

  //             return ListView.builder(
  //               itemCount: participatedChatIds.length,
  //               itemBuilder: (context, index) {
  //                 String chatId = participatedChatIds[index];
  //                 Map<dynamic, dynamic> chat =
  //                     data[chatId] as Map<dynamic, dynamic>;

  //                 // Sort the messageKeys based on timestamp
  //                 List<String> messageKeys = chat.keys.cast<String>().toList();
  //                 messageKeys.sort((a, b) {
  //                   int timestampA = chat[a]['timestamp'] ?? 0;
  //                   int timestampB = chat[b]['timestamp'] ?? 0;
  //                   return timestampB
  //                       .compareTo(timestampA); // Sort in descending order
  //                 });

  //                 String lastMessageId =
  //                     messageKeys.first; // Get the last message ID

  //                 Map<dynamic, dynamic> messageData =
  //                     chat[lastMessageId] as Map<dynamic, dynamic>;

  //                 //assigning emoji id and username
  //                 // if (currentUserId == messageData['chatlistSenderId']) {
  //                 //   emojiId = messageData['senderEmojiId'];
  //                 //   userName = messageData['senderUserName'];
  //                 //   print('iiiiiiiiiiffff $userName');
  //                 // } else if (currentUserId ==
  //                 //     messageData['chatlistReceiverId']) {
  //                 //   emojiId = messageData['receiverEmojiId'];
  //                 //   userName = messageData['receiverUserName'];
  //                 //   print('else   iiiiiiiiiiffff $userName');
  //                 // }

  //                 String lastMessage = messageData['message'] ?? '';
  //                 int timestamp = messageData['timestamp'] ?? 0;

  //                 // Format the timestamp into a human-readable date and time format
  //                 String formattedDateTime = _formatTimestamp(timestamp);

  //                 requestsRef
  //                     .orderByChild('receiverId')
  //                     .equalTo(currentUserId)
  //                     .onValue
  //                     .listen((event) {
  //                   DataSnapshot snapshot = event.snapshot;

  //                   if (snapshot != null && snapshot.value != null) {
  //                     Map<dynamic, dynamic> requestsData =
  //                         snapshot.value as Map<dynamic, dynamic>;

  //                     List<Widget> requestWidgets = [];

  //                     requestsData.forEach((requestId, requestData) {
  //                       if (currentUserId == requestData['senderId']) {
  //                         emojiId = requestData['senderEmojiId'];
  //                         userName = requestData['senderUserName'];
  //                         print('get data iiiiiiiiffffffff');

  //                         print('username $userName');
  //                       } else {
  //                         emojiId = requestData['receiverEmojiId'];
  //                         userName = requestData['receiverUserName'];
  //                         print('get data eeeeeeeelse');
  //                         print('username $userName');
  //                       }
  //                     });

  //                     // Now you can use the requestWidgets list as needed.
  //                   }
  //                 }, onError: (error) {
  //                   // Handle any errors that may occur during data retrieval.
  //                   print('Error: $error');
  //                 });

  //                 Avatar? matchingAvatar = avatars.firstWhere(
  //                   (avatar) => avatar.id == int.tryParse(emojiId),
  //                   orElse: () => Avatar(id: 0, imagePath: ''),
  //                 );

  //                 return Card(
  //                   child: ListTile(
  //                     leading: CircleAvatar(
  //                       backgroundImage: AssetImage(matchingAvatar.imagePath),
  //                     ),
  //                     title: Text(userName),
  //                     subtitle: Row(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Expanded(
  //                           child: Text(
  //                             lastMessage,
  //                             overflow: TextOverflow.ellipsis,
  //                             maxLines:
  //                                 1, // Display only one line of the last message
  //                           ),
  //                         ),
  //                         SizedBox(
  //                             width:
  //                                 8), // Add some space between the message and the date
  //                         Text(
  //                           formattedDateTime,
  //                           style: TextStyle(
  //                             fontSize: 12,
  //                             color: Colors.grey,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     //subtitle: Text(lastMessage),
  //                     onTap: () {
  //                       Navigator.push(
  //                         context,
  //                         MaterialPageRoute(
  //                           builder: (context) => ChatScreen(
  //                             chatId: chatId,
  //                             imagePath: matchingAvatar.imagePath,
  //                             userName: userName,
  //                           ),
  //                         ),
  //                       );
  //                     },
  //                   ),
  //                 );
  //               },
  //             );
  //           }
  //         }

  //         return Center(
  //           child: Text("No Private chat list"),
  //         );
  //       },
  //     ),
  //   );
  // }

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
                // itemCount: participatedChatIds.length,
                itemCount: chatDataList.length,

                itemBuilder: (context, index) {
                  //testing start
                  Map<dynamic, dynamic> chatData = chatDataList[index];
                  String emojiId = chatData['emojiId'];
                  String userName = chatData['userName'];
                  //testing end
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

                  String lastMessage = messageData['message'] ?? '';
                  int timestamp = messageData['timestamp'] ?? 0;

                  // Format the timestamp into a human-readable date and time format
                  String formattedDateTime = _formatTimestamp(timestamp);

                  Avatar? matchingAvatar = avatars.firstWhere(
                    (avatar) => avatar.id == int.tryParse(emojiId),
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
