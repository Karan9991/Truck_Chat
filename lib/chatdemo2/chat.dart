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

  @override
  void initState() {
    super.initState();

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

  void _sendMessage() async {
  bool isSenderBlocked = await isUserBlocked(widget.userId, widget.receiverId);
  bool isReceiverBlocked = await isUserBlocked(widget.receiverId, widget.userId);

  if (isSenderBlocked) {
    // Show a snackbar message indicating that the sender has blocked the receiver
    _showBlockedMessage("You blocked this user. Cannot send a message.");
    return;
  } else if (isReceiverBlocked) {
    // Show a snackbar message indicating that the receiver has blocked the sender
    _showBlockedMessage("This user has blocked you. Cannot send a message.");
    return;
  }

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
   bool isSenderBlocked = await isUserBlocked(widget.userId, widget.receiverId);
  bool isReceiverBlocked = await isUserBlocked(widget.receiverId, widget.userId);

  if (isSenderBlocked) {
    // Show a snackbar message indicating that the sender has blocked the receiver
    _showBlockedMessage("You blocked this user. Cannot send a message.");
    return;
  } else if (isReceiverBlocked) {
    // Show a snackbar message indicating that the receiver has blocked the sender
    _showBlockedMessage("This user has blocked you. Cannot send a message.");
    return;
  }
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

void _showBlockedMessage(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    ),
  );
}


  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _blockUser(String currentUserID, String blockedUserID) {
    // Add the blockedUserID to the currentUserID's blocked users list
    _databaseReference
        .child('blockedUsers')
        .child(currentUserID)
        .child(blockedUserID)
        .set(true)
        .then((_) {
      // Successfully blocked the user, show a success message
      _showSuccessMessage("User blocked successfully!");
    }).catchError((error) {
      // An error occurred while blocking the user, show an error message
      _showErrorMessage("Failed to block user. Please try again.");
    });
  }

  void _unblockUser(String currentUserID, String blockedUserID) {
    // Remove the blockedUserID from the currentUserID's blocked users list
    _databaseReference
        .child('blockedUsers')
        .child(currentUserID)
        .child(blockedUserID)
        .remove()
        .then((_) {
      // Successfully unblocked the user, show a success message
      _showSuccessMessage("User unblocked successfully!");
    }).catchError((error) {
      // An error occurred while unblocking the user, show an error message
      _showErrorMessage("Failed to unblock user. Please try again.");
    });
  }

  void _showOptionsMenu(BuildContext context, bool isBlocked) {
    String currentUserID = widget.userId;
    String blockedUserID = widget.receiverId;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(isBlocked ? Icons.block : Icons.block_outlined),
                title: Text(isBlocked ? 'Unblock user' : 'Block user'),
                onTap: () {
                  Navigator.pop(context); // Close the options menu
                  if (isBlocked) {
                    _unblockUser(currentUserID, blockedUserID);
                  } else {
                    _blockUser(currentUserID, blockedUserID);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> isUserBlocked(String currentUserID, String targetUserID) async {
    DatabaseEvent event = await _databaseReference
        .child('blockedUsers')
        .child(currentUserID)
        .child(targetUserID)
        .once();

    DataSnapshot snapshot = event.snapshot;

    // Check if the snapshot value exists and is not null
    return snapshot.exists && snapshot.value != null;
  }

  @override
  Widget build(BuildContext context) {
    _messages.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: Text('Block this user'),
                  value: 'block this user',
                ),
              ];
            },
            onSelected: (value) async {
              // Perform action when a pop-up menu item is selected
              switch (value) {
                case 'block this user':
                  // Get the block status for the current user and receiver
                  // You can use the isUserBlocked function to get the block status
                  // Here, I'm assuming you have the function isUserBlocked implemented
                  bool isBlocked =
                      await isUserBlocked(widget.userId, widget.receiverId);

                  _showOptionsMenu(context, isBlocked);
                  break;
              }
            },
          ),
        ],
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
