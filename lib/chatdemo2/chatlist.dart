import 'package:chat/chatdemo2/chat.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();
  List<Map<dynamic, dynamic>> _chatList = [];

  String userId = '2';

  @override
  void initState() {
    super.initState();

    _loadChatList(userId);
  }

  void _loadChatList(String userId) {
    print("Fetching chat lists for user: $userId");

    _databaseReference.child('chatList').child(userId).onValue.listen((event) {
      DataSnapshot snapshot = event.snapshot;
      print('chatList ${snapshot.value}');
      if (snapshot.value != null) {
        if (snapshot.value is Map) {
          Map<dynamic, dynamic> chatListData =
              snapshot.value as Map<dynamic, dynamic>;
          List<Map<dynamic, dynamic>> chatLists = [];

          chatListData.forEach((key, value) {
            if (value != null && value is Map) {
              chatLists.add(Map<dynamic, dynamic>.from(value));
            }
          });

          setState(() {
            _chatList = chatLists;
          });

          print("Chat list loaded. Total chat lists: ${_chatList.length}");
          print("Chat list content: $_chatList");
        } else if (snapshot.value is List) {
          List<dynamic> chatListData = snapshot.value as List<dynamic>;
          List<Map<dynamic, dynamic>> chatLists = [];

          chatListData.forEach((value) {
            if (value != null && value is Map) {
              chatLists.add(Map<dynamic, dynamic>.from(value));
            }
          });

          setState(() {
            _chatList = chatLists;
          });

          print("Chat list loaded. Total chat lists: ${_chatList.length}");
          print("Chat list content: $_chatList");
        } else {
          print("Invalid chat list data format for user: $userId");
          setState(() {
            _chatList = [];
          });
        }
      } else {
        print("No chat lists found for user: $userId");
        setState(() {
          _chatList = [];
        });
      }
    });
  }

  void _deleteChat(int index) {
    print('deleteChat');
    // Assuming the user is already authenticated with Firebase Authentication
    // Replace 'userId' with the authenticated user's ID
    String userId = '1'; // Change this to the authenticated user's ID

    // Get the chat item corresponding to the selected index
    Map<dynamic, dynamic> chatItem = _chatList[index];
    String receiverId = chatItem['receiverId'];

    // Remove the chat list entry for the selected user from the current user's chat list
    _databaseReference
        .child('chatList')
        .child(userId)
        .child(receiverId)
        .remove();

    // If needed, you can also remove the chat list entry for the current user from the selected user's chat list
    // _databaseReference.child('chatList').child(receiverId).child(userId).remove();
  }

  @override
  Widget build(BuildContext context) {
    _chatList.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat List'),
      ),
      body: ListView.builder(
        itemCount: _chatList.length,
        itemBuilder: (context, index) {
          Map<dynamic, dynamic> chatItem = _chatList[index];
          return ListTile(
            // leading: CircleAvatar(
            //   backgroundImage: NetworkImage(chatItem['userImage']),
            // ),
            title: Text(chatItem['userName']),
            subtitle: Text(
              chatItem['lastMessage'],
              style: TextStyle(
                fontWeight: chatItem['newMessages']
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            trailing: chatItem['newMessages']
                ? CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      chatItem['newMessageCount'].toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : null,
            onTap: () {
              // Open the chat screen with the selected user
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    userId: userId, // Change this to the authenticated user's ID
                    receiverId: chatItem['receiverId'],
                    receiverName: chatItem['userName'],
                  ),
                ),
              );
            },
            onLongPress: () {
              // Delete the chat on long press
              _deleteChat(index);
            },
          );
        },
      ),
    );
  }
}





  // void _loadChatList() {
  //   // Assuming the user is already authenticated with Firebase Authentication
  //   // Replace 'userId' with the authenticated user's ID
  //   String userId = '1'; // Change this to the authenticated user's ID
  //   _databaseReference.child('chatList').child(userId).child('2').onValue.listen((event) {
  //     DataSnapshot snapshot = event.snapshot;
  //     if (snapshot.value != null) {
  //       setState(() {

  //                if (snapshot.value != null) {
  //     if (snapshot.value is List) {
  //       setState(() {
  //         _chatList = (snapshot.value as List).cast<Map<dynamic, dynamic>>();
  //       });
  //     } else if (snapshot.value is Map) {
  //       // Handle single item case (only one user in the list)
  //       setState(() {
  //         _chatList = [snapshot.value as Map<dynamic, dynamic>];
  //       });
  //     }
  //   }

  //       });
  //     }
  //   });
  // }
          // _chatList = List<Map<dynamic, dynamic>>.from(snapshot.value);
         // _chatList = (snapshot.value as List<dynamic>).cast<Map<dynamic, dynamic>>();



//issue

//one item
// void _loadChatList(String userId) {
//   print("Fetching chat lists for user: $userId");

//   _databaseReference.child('chatList').child(userId).onValue.listen((event) {
//     DataSnapshot snapshot = event.snapshot;
//     print('chatList ${snapshot.value}');
//     if (snapshot.value != null) {
//       Map<dynamic, dynamic>? chatListData = snapshot.value as Map<dynamic, dynamic>?;

//       if (chatListData != null) {
//         List<Map<dynamic, dynamic>> chatLists = [];

//         chatListData.forEach((key, value) {
//           if (value != null && value is Map) {
//             chatLists.add(Map<dynamic, dynamic>.from(value));
//           }
//         });

//         setState(() {
//           _chatList = chatLists;
//         });

//         print("Chat list loaded. Total chat lists: ${_chatList.length}");
//         print("Chat list content: $_chatList");
//       } else {
//         print("Invalid chat list data format for user: $userId");
//         setState(() {
//           _chatList = [];
//         });
//       }
//     } else {
//       print("No chat lists found for user: $userId");
//       setState(() {
//         _chatList = [];
//       });
//     }
//   });
// }


//more than one items

  // void _loadChatList(String userId) {
  //   print("Fetching chat lists for user: $userId");

  //   _databaseReference.child('chatList').child(userId).onValue.listen((event) {
  //     DataSnapshot snapshot = event.snapshot;
  //     print('chatlsit ${snapshot.value}');
  //     if (snapshot.value != null) {
  //       setState(() {
  //         _chatList = [];

  //         if (snapshot.value is List) {
  //           // Loop through each item in the list and add them to the _chatList
  //           (snapshot.value as List<dynamic>).forEach((chatData) {
  //             if (chatData != null && chatData is Map) {
  //               _chatList.add(chatData);
  //             }
  //           });
  //         }

  //         print("Chat list loaded. Total chat lists: ${_chatList.length}");
  //         print("Chat list content: $_chatList");
  //       });
  //     } else {
  //       print("No chat lists found for user: $userId");
  //     }
  //   });
  // }