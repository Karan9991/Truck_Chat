import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String receiverId;
  final String receiverName;

  ChatScreen({
    required this.userId,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _messageController = TextEditingController();
  DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();
  List<Map<dynamic, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();

    DatabaseReference requestRef = FirebaseDatabase.instance
        .ref()
        .child('chatList')
        .child(widget.userId)
        .child(widget.receiverId);

    requestRef.update({'newMessages': false});

    _loadMessages();
  }

  void _loadMessages() {
    _databaseReference
        .child('messages')
        .child(widget.userId)
        .child(widget.receiverId)
        .onValue
        .listen((event) {
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null && snapshot.value is Map) {
        Map<dynamic, dynamic>? messageMap =
            snapshot.value as Map<dynamic, dynamic>?;
        if (messageMap != null) {
          List<Map<dynamic, dynamic>> messagesList = [];

          // Convert the map of messages to a list of messages
          messageMap.forEach((key, value) {
            messagesList.add(value);
          });

          setState(() {
            _messages = messagesList;
          });
        }
      } else {
        setState(() {
          _messages = [];
        });
      }
    });
  }

  void _sendMessage() {
    String messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      _messageController.clear();
      var timestamp = DateTime.now().millisecondsSinceEpoch;

      // Send the message to the receiver
      _databaseReference
          .child('messages')
          .child(widget.userId)
          .child(widget.receiverId)
          .push()
          .set({
        'senderId': widget.userId,
        'receiverId': widget.receiverId,
        'message': messageText,
        'timestamp': timestamp,
      });

      _databaseReference
          .child('messages')
          .child(widget.receiverId)
          .child(widget.userId)
          .push()
          .set({
        'senderId': widget.userId,
        'receiverId': widget.receiverId,
        'message': messageText,
        'timestamp': timestamp,
      });

      // Update the chat list for the sender (widget.userId)
      _updateChatList(widget.userId, widget.receiverId, messageText, timestamp);

      // Update the chat list for the receiver (widget.receiverId)
      _updateChatList(widget.receiverId, widget.userId, messageText, timestamp);
    }
  }

  void _updateChatList(String userId, String otherUserId, String lastMessage,
      int timestamp) async {
    try {
      DataSnapshot snapshot = await _databaseReference
          .child('chatList')
          .child(userId)
          .child(otherUserId)
          .get();
      if (snapshot.value != null) {
        // Chat already exists, update last message and timestamp
        await _databaseReference
            .child('chatList')
            .child(userId)
            .child(otherUserId)
            .update({
          'lastMessage': lastMessage,
          'timestamp': timestamp,
          'newMessages':
              true, // Set newMessages to true to indicate there are new messages
        });
      } else {
        // Chat does not exist, create a new chat list entry
        DataSnapshot userSnapshot =
            await _databaseReference.child('users').child(otherUserId).get();
        Map<dynamic, dynamic>? userData =
            userSnapshot.value as Map<dynamic, dynamic>?;
        String otherUserName = userData?['userName'] ?? 'Unknown User';
        String otherUserImage = userData?['userImage'] ?? 'default_image_url';

        await _databaseReference
            .child('chatList')
            .child(userId)
            .child(otherUserId)
            .set({
          'userName': otherUserName,
          'userImage': otherUserImage,
          'receiverId': otherUserId,
          'lastMessage': lastMessage,
          'timestamp': timestamp,
          'newMessages': true,
        });
      }
    } catch (error) {
      print('Error updating chat list: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                Map<dynamic, dynamic> message = _messages[index];
                bool isSender = message['senderId'] == widget.userId;
                return Align(
                  alignment: isSender ? Alignment.topRight : Alignment.topLeft,
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    margin: EdgeInsets.symmetric(vertical: 4.0),
                    decoration: BoxDecoration(
                      color: isSender ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Text(
                      message['message'],
                      style: TextStyle(
                          color: isSender ? Colors.white : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
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





        // _messages = List<Map<dynamic, dynamic>>.from(snapshot.value);

          //_messages = (snapshot.value as List<dynamic>).cast<Map<dynamic, dynamic>>();
  // void _loadMessages() {
  //   _databaseReference
  //       .child('messages')
  //       .child(widget.userId)
  //       .child(widget.receiverId)
  //       .onValue
  //       .listen((event) {
  //     DataSnapshot snapshot = event.snapshot;
  //     if (snapshot.value != null) {
  //       setState(() {
          // if (snapshot.value != null) {
          //   if (snapshot.value is List) {
          //     setState(() {
          //       _messages =
          //           (snapshot.value as List).cast<Map<dynamic, dynamic>>();
          //     });
          //   } else if (snapshot.value is Map) {
          //     // Handle single item case (only one message in the list)
          //     setState(() {
          //       _messages = [snapshot.value as Map<dynamic, dynamic>];
          //     });
          //   }
          // }
  //       });
  //     }
  //   });
  // }




  // void _sendMessage() {
  //   String messageText = _messageController.text.trim();
  //   if (messageText.isNotEmpty) {
  //     _messageController.clear();
  //     var timestamp = DateTime.now().millisecondsSinceEpoch;
  //     _databaseReference
  //         .child('messages')
  //         .child(widget.userId)
  //         .child(widget.receiverId)
  //         .push()
  //         .set({
  //       'senderId': widget.userId,
  //       'receiverId': widget.receiverId,
  //       'message': messageText,
  //       'timestamp': timestamp,
  //     });

  //     _databaseReference
  //         .child('messages')
  //         .child(widget.receiverId)
  //         .child(widget.userId)
  //         .push()
  //         .set({
  //       'senderId': widget.userId,
  //       'receiverId': widget.receiverId,
  //       'message': messageText,
  //       'timestamp': timestamp,
  //     });
  //   }
  // }


  // void _updateChatList(String userId, String otherUserId, String lastMessage, int timestamp) {
//   _databaseReference.child('chatList').child(userId).child(otherUserId).once().then((DataSnapshot snapshot) {
//     if (snapshot.value != null) {
//       // Chat already exists, update last message and timestamp
//       _databaseReference.child('chatList').child(userId).child(otherUserId).update({
//         'lastMessage': lastMessage,
//         'timestamp': timestamp,
//         'newMessages': true, // Set newMessages to true to indicate there are new messages
//       });
//     } else {
//       // Chat does not exist, create a new chat list entry
//       _databaseReference.child('users').child(otherUserId).once().then((DataSnapshot userSnapshot) {
//         String otherUserName = userSnapshot.value['userName'];
//         String otherUserImage = userSnapshot.value['userImage'];

//         _databaseReference.child('chatList').child(userId).child(otherUserId).set({
//           'userName': otherUserName,
//           'userImage': otherUserImage,
//           'lastMessage': lastMessage,
//           'timestamp': timestamp,
//           'newMessages': true,
//         });
//       });
//     }
//   });
// }

// void _updateChatList(String userId, String otherUserId, String lastMessage, int timestamp) async {
//   try {
//     DataSnapshot snapshot = await _databaseReference.child('chatList').child(userId).child(otherUserId).get();
//     if (snapshot.value != null) {
//       // Chat already exists, update last message and timestamp
//       await _databaseReference.child('chatList').child(userId).child(otherUserId).update({
//         'lastMessage': lastMessage,
//         'timestamp': timestamp,
//         'newMessages': true, // Set newMessages to true to indicate there are new messages
//       });
//     } else {
//       // Chat does not exist, create a new chat list entry
//       DataSnapshot userSnapshot = await _databaseReference.child('users').child(otherUserId).get();
//       Map<dynamic, dynamic>? userData = userSnapshot.value;
//       String otherUserName = userData?['userName'] ?? 'Unknown User';
//       String otherUserImage = userData?['userImage'] ?? 'default_image_url';

//       await _databaseReference.child('chatList').child(userId).child(otherUserId).set({
//         'userName': otherUserName,
//         'userImage': otherUserImage,
//         'lastMessage': lastMessage,
//         'timestamp': timestamp,
//         'newMessages': true,
//       });
//     }
//   } catch (error) {
//     print('Error updating chat list: $error');
//   }
// }