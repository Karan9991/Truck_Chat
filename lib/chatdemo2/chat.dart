import 'dart:io';

import 'package:chat/utils/alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
  DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  List<Map<dynamic, dynamic>> _messages = [];
  late DatabaseReference _chatRefs;

  @override
  void initState() {
    super.initState();

    _chatRefs = FirebaseDatabase.instance
        .ref()
        .child('messages')
        .child(widget.userId)
        .child(widget.receiverId);

    _updateNewMessage();

    _loadMessages();
  }

  void _updateNewMessage() async {
    DataSnapshot snapshot = await _databaseReference
        .child('chatList')
        .child(widget.userId)
        .child(widget.receiverId)
        .get();
    if (snapshot.value != null) {
      DatabaseReference updateNewMessage = FirebaseDatabase.instance
          .ref()
          .child('chatList')
          .child(widget.userId)
          .child(widget.receiverId);

      updateNewMessage.update({'newMessages': false});
    }
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

  Future<void> _sendImage() async {
    sendImageDialog(context, () => _openCamera(), () => _openGallery());
  }

  Future<void> _openCamera() async {
    final ImagePicker _picker = ImagePicker();
    XFile? pickedFile = await _picker.pickImage(
      source: ImageSource
          .camera, // Change this to ImageSource.camera for camera access
    );

    if (pickedFile != null) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(File(pickedFile.path));

      try {
        TaskSnapshot taskSnapshot = await uploadTask;
        String imageUrl = await taskSnapshot.ref.getDownloadURL();

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
          'message': imageUrl,
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
          'message': imageUrl,
          'timestamp': timestamp,
        });

        // Update the chat list for the sender (widget.userId)
        _updateChatList(widget.userId, widget.receiverId, imageUrl, timestamp);

        // Update the chat list for the receiver (widget.receiverId)
        _updateChatList(widget.receiverId, widget.userId, imageUrl, timestamp);

      } catch (error) {
        print('Error uploading image: $error');
      }
    }
  }

  Future<void> _openGallery() async {
    final ImagePicker _picker = ImagePicker();
    XFile? pickedFile = await _picker.pickImage(
      source: ImageSource
          .gallery, // Change this to ImageSource.camera for camera access
    );

    if (pickedFile != null) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(File(pickedFile.path));

      try {
        TaskSnapshot taskSnapshot = await uploadTask;
        String imageUrl = await taskSnapshot.ref.getDownloadURL();
        var timestamp = DateTime.now().millisecondsSinceEpoch;

        _databaseReference
            .child('messages')
            .child(widget.userId)
            .child(widget.receiverId)
            .push()
            .set({
          'senderId': widget.userId,
          'receiverId': widget.receiverId,
          'message': imageUrl,
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
          'message': imageUrl,
          'timestamp': timestamp,
        });

        // Update the chat list for the sender (widget.userId)
        _updateChatList(widget.userId, widget.receiverId, imageUrl, timestamp);

        // Update the chat list for the receiver (widget.receiverId)
        _updateChatList(widget.receiverId, widget.userId, imageUrl, timestamp);

      } catch (error) {
        print('Error uploading image: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _messages.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

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

                //testing start
                String messages = message['message'] ?? '';
                String imageUrl = messages.startsWith('https') ? messages : '';
                bool isImageMessage = imageUrl.isNotEmpty;

                return MessageBubble(
                  message: messages,
                  isCurrentUser: isSender,
                  isImageMessage: isImageMessage,
                  imageUrl: imageUrl,
                );
                //testing end
                // return Align(
                //   alignment: isSender ? Alignment.topRight : Alignment.topLeft,
                //   child: Container(
                //     padding: EdgeInsets.all(8.0),
                //     margin: EdgeInsets.symmetric(vertical: 4.0),
                //     decoration: BoxDecoration(
                //       color: isSender ? Colors.blue : Colors.grey[300],
                //       borderRadius: BorderRadius.circular(16.0),
                //     ),
                //     child: Text(
                //       message['message'],
                //       style: TextStyle(
                //           color: isSender ? Colors.white : Colors.black),
                //     ),
                //   ),
                // );
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
                SizedBox(
                    width:
                        8), // Add some space between the text field and the send button
                IconButton(
                  onPressed:
                      _sendImage, // Call the function to open the gallery
                  icon: Icon(
                    Icons.image,
                    color: Colors.blue[300],
                  ), // You can use any other icon here
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
  final bool
      isImageMessage; // Add a new boolean variable to identify image messages
  final String imageUrl; // Add a new variable to store the image URL

  MessageBubble({
    required this.message,
    required this.isCurrentUser,
    required this.isImageMessage,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: () {
          // Open the full image when tapped
          if (isImageMessage) {
            _showFullImage(context, imageUrl);
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: isCurrentUser ? Colors.blue[400] : Colors.grey[300],
            borderRadius: BorderRadius.circular(16),
          ),
          child: isImageMessage
              ? Image.network(
                  imageUrl,
                  width:
                      200, // Set the width of the image as per your requirement
                  height:
                      200, // Set the height of the image as per your requirement
                  fit: BoxFit.cover, // Adjust the image fit as needed
                )
              : Text(
                  message,
                  style: TextStyle(
                      color: isCurrentUser ? Colors.white : Colors.black),
                ),
        ),
      ),
    );
  }
}

void _showFullImage(BuildContext context, String imageUrl) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Scaffold(
        body: Center(
          child: PhotoView(
            imageProvider: NetworkImage(imageUrl),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2.0,
          ),
        ),
      ),
    ),
  );
}
